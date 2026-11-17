"""删除资料的提交边界回归测试；不连接数据库、Chroma 或模型服务。"""
import os
import unittest
from types import SimpleNamespace
from unittest.mock import patch

os.environ.setdefault("DATABASE_URL", "sqlite://")
os.environ.setdefault("JWT_SECRET_KEY", "delete-regression-test")

from app.common.exceptions import BusinessException
from app.services import document_service


class FakeDatabase:
    def __init__(self, mode, events):
        self.mode = mode
        self.events = events
        self.row = SimpleNamespace(id=1, rel_path="document.txt", ingested=True)
        self.present = True
        self.pending_delete = False
        self.commit_count = 0
        self.query_count = 0

    def scalar(self, statement):
        self.query_count += 1
        self.events.append("query")
        if self.mode == "verification_failure" and self.query_count > 1:
            raise RuntimeError("injected verification failure")
        return self.row if self.present else None

    def delete(self, row):
        self.events.append("delete_pending")
        self.pending_delete = True

    def commit(self):
        self.commit_count += 1
        if self.commit_count == 1 and self.mode in {
            "before_commit", "verification_failure", "repair_failure"
        }:
            raise RuntimeError("injected failure before persistence")
        if self.commit_count == 2 and self.mode == "repair_failure":
            raise RuntimeError("injected status repair failure")
        if self.pending_delete:
            self.present = False
            self.pending_delete = False
            self.events.append("delete_committed")
        if self.commit_count == 1 and self.mode == "ack_lost":
            raise RuntimeError("injected lost commit acknowledgement")

    def rollback(self):
        self.events.append("rollback")
        self.pending_delete = False


class DeleteDocumentRegression(unittest.TestCase):
    def run_delete(self, mode="normal", vector_error=False, file_error=False):
        events = []
        db = FakeDatabase(mode, events)
        state = {"file_exists": True, "vectors_exist": True}

        def remove_vectors(doc_id):
            events.append("delete_vectors")
            if vector_error:
                raise RuntimeError("injected vector failure")
            state["vectors_exist"] = False

        def unlink(missing_ok=False):
            events.append("unlink")
            if file_error:
                raise OSError("injected file removal failure")
            state["file_exists"] = False

        error = None
        with patch.object(document_service, "document_path", return_value=SimpleNamespace(unlink=unlink)), \
             patch.object(document_service, "delete_by_doc_id", side_effect=remove_vectors), \
             patch.object(document_service.logger, "exception"):
            try:
                document_service.delete_document(db, 1)
            except BusinessException as exc:
                error = exc
        return db, state, events, error

    def test_success_removes_file_only_after_database_commit(self):
        db, state, events, error = self.run_delete()
        self.assertIsNone(error)
        self.assertFalse(db.present)
        self.assertFalse(state["file_exists"])
        self.assertLess(events.index("delete_committed"), events.index("unlink"))

    def test_failed_commit_preserves_file_and_allows_reingestion(self):
        db, state, events, error = self.run_delete("before_commit")
        self.assertIsNotNone(error)
        self.assertIn("原文件已保留", error.message)
        self.assertTrue(db.present)
        self.assertTrue(state["file_exists"])
        self.assertFalse(db.row.ingested)
        self.assertNotIn("unlink", events)

    def test_lost_acknowledgement_returns_success_after_verifying_deletion(self):
        db, state, events, error = self.run_delete("ack_lost")
        self.assertIsNone(error)
        self.assertFalse(db.present)
        self.assertFalse(state["file_exists"])
        self.assertEqual(db.query_count, 2)
        self.assertLess(events.index("delete_committed"), events.index("unlink"))

    def test_uncertain_commit_status_preserves_file(self):
        db, state, events, error = self.run_delete("verification_failure")
        self.assertIn("删除状态不确定", error.message)
        self.assertTrue(state["file_exists"])
        self.assertNotIn("unlink", events)

    def test_vector_failure_preserves_record_and_file(self):
        db, state, events, error = self.run_delete(vector_error=True)
        self.assertIsNotNone(error)
        self.assertTrue(db.present)
        self.assertTrue(state["file_exists"])
        self.assertTrue(db.row.ingested)

    def test_failed_status_repair_preserves_file(self):
        db, state, events, error = self.run_delete("repair_failure")
        self.assertIn("清理未完成", error.message)
        self.assertTrue(state["file_exists"])
        self.assertNotIn("unlink", events)

    def test_file_cleanup_failure_reports_committed_deletion(self):
        db, state, events, error = self.run_delete(file_error=True)
        self.assertIn("记录和向量已删除", error.message)
        self.assertFalse(db.present)
        self.assertFalse(state["vectors_exist"])
        self.assertTrue(state["file_exists"])


if __name__ == "__main__":
    unittest.main()
