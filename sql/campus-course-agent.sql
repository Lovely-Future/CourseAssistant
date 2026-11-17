-- 校园课程智能助手：完整初始化 SQL（已包含最终表结构，无需再执行迁移脚本）。
-- 导入会删除并重建 campus_course_agent，仅用于可覆盖的本地演示环境。
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: campus_course_agent
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `campus_course_agent`
--

/*!40000 DROP DATABASE IF EXISTS `campus_course_agent`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `campus_course_agent` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `campus_course_agent`;

--
-- Table structure for table `coruses`
--

DROP TABLE IF EXISTS `coruses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coruses` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程名词',
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程编码',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '课程简介',
  `status` int NOT NULL COMMENT '状态：0-停用，1-正常',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coruses`
--

LOCK TABLES `coruses` WRITE;
/*!40000 ALTER TABLE `coruses` DISABLE KEYS */;
INSERT INTO `coruses` VALUES (1,'大学英语','ENG102','听说读写综合训练',1,'2026-09-28 11:07:57','2026-09-28 11:22:01'),(2,'数据结构','DS101','线性表、树、图与常用算法',1,'2026-09-28 11:08:28','2026-09-28 11:08:28'),(3,'高等数学','MATH101','极限、导数与积分',1,'2026-09-28 11:08:45','2026-09-28 11:36:20');
/*!40000 ALTER TABLE `coruses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '学生ID',
  `class_date` date NOT NULL COMMENT '上课日期',
  `period` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节次',
  `course_id` int NOT NULL COMMENT '课程ID',
  `location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '地点',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `coruses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课表信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (1,2,'2026-10-10','1-2节',1,'B教 105','2026-09-28 16:49:35','2026-09-28 17:32:48'),(3,2,'2026-10-11','5-6节',3,'A教201','2026-09-28 17:33:18','2026-09-28 17:33:18'),(4,2,'2026-10-12','3-4节',2,'A教201','2026-09-28 17:33:34','2026-09-28 17:33:34');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_plan`
--

DROP TABLE IF EXISTS `study_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_plan` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '计划内容',
  `turn_id` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'MCP对话轮次ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_study_plan_user_turn` (`user_id`,`turn_id`),
  CONSTRAINT `study_plan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习计划';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_plan`
--

LOCK TABLES `study_plan` WRITE;
/*!40000 ALTER TABLE `study_plan` DISABLE KEYS */;
INSERT INTO `study_plan` VALUES (3,2,'明天数据结构课前，把链表与二叉树笔记过一遍，并完成课后习题 1～3。',NULL,'2026-09-29 10:37:25','2026-09-29 10:37:25'),(4,2,'## 本周复习\n- 高等数学：导数练习\n- 大学英语：Unit 3 单词',NULL,'2026-09-29 10:37:32','2026-09-29 10:37:32');
/*!40000 ALTER TABLE `study_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色：student-学生，admin-管理员',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像',
  `status` int NOT NULL COMMENT '状态：0-禁用，1-正常',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2b$12$ypJClLKejFCsyn2eltOco.YAmXory0HFjh7E/oHu9MBzDZZ6wYSSi','管理员','admin','admin@system.cn','13988776699','/uploads/1790046856623_dc4830aa.jpg',1,'2026-09-11 15:30:07','2026-09-22 11:14:34'),(2,'aaa','$2a$10$phJ2k4sP5.c7T/LuXwzyTu/AlbbOFXblsAZEW6mIfh3koVxQ3Hhny','小白','student','xiaobai@qq.com','13899776688','/uploads/1790046891012_452a9884.png',1,'2026-09-09 16:56:41','2026-09-22 11:14:52'),(3,'bbb','$2a$10$blJ4Qgbaqxm5jmUAWvuiRuKy/FiqbmFv.n1i0noM3pxUZrYhd2HNK','小黑','student','xiaohei@163.com','13799886699','/uploads/1790046917012_b9ee534a.png',1,'2026-09-22 11:15:00','2026-09-22 11:15:30'),(4,'ccc','$2b$12$mdFV7.VhTkjSUOLFhcn3L.tDc3S0vtM4JF7fuIkqPoO5MKFDqwPLe','ccc','student',NULL,NULL,NULL,1,'2026-09-24 15:29:34','2026-09-24 15:29:34');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kb_documents`
-- 原文件和向量属于本机运行数据，不附带旧文件路径或已入库标记。
--

DROP TABLE IF EXISTS `kb_documents`;
CREATE TABLE `kb_documents` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `original_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始文件名',
  `disk_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '磁盘文件名',
  `rel_path` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '相对 data/kb 的路径',
  `size` int NOT NULL COMMENT '字节数',
  `ext` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '扩展名',
  `ingested` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已写入共享向量库',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `original_name` (`original_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识库文档';

--
-- Dumping events for database 'campus_course_agent'
--

--
-- Dumping routines for database 'campus_course_agent'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-26 18:24:58
