-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: sip-k
-- ------------------------------------------------------
-- Server version	8.4.3

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
-- Table structure for table `app_notifications`
--

DROP TABLE IF EXISTS `app_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `app_notifications_user_id_foreign` (`user_id`),
  CONSTRAINT `app_notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_notifications`
--

LOCK TABLES `app_notifications` WRITE;
/*!40000 ALTER TABLE `app_notifications` DISABLE KEYS */;
INSERT INTO `app_notifications` VALUES (1,1,'Pengajuan Disetujui (Nota Dinas Terbit)','Permohonan armada Toyota Avanza 1.3 Veloz telah disetujui. Softfile Nota Dinas resmi telah tersedia untuk dicetak dan diserahkan ke Kasubag TU.','ND-5519/DINSOS/2026','approved',0,'2026-09-22 21:40:30','2026-09-22 21:40:30'),(2,1,'Permohonan Berhasil Dikirim','Pengajuan peminjaman unit Toyota Innova Reborn 2.4 G (REQ-2026-0902-001) telah berhasil diajukan dan sedang menunggu verifikasi Kasubag.','REQ-2026-0902-001','submitted',1,'2026-09-22 21:40:30','2026-09-22 21:40:30'),(3,1,'Pengembalian Selesai (BAST Terbit)','Unit Toyota Innova Reborn 2.4 G telah selesai diperiksa oleh tim aset dan dikembalikan ke pool kendaraan dinas. Terima kasih.','BAST-2026-0829-01','returned',1,'2026-09-22 21:40:30','2026-09-22 21:40:30');
/*!40000 ALTER TABLE `app_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loans`
--

DROP TABLE IF EXISTS `loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loans` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `borrower_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination_address` text COLLATE utf8mb4_unicode_ci,
  `purpose_description` text COLLATE utf8mb4_unicode_ci,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `official_note_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '-',
  `sim_photo_path` longtext COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `submitted_at` datetime NOT NULL,
  `spk_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `return_odometer` int DEFAULT NULL,
  `return_fuel` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `return_notes` text COLLATE utf8mb4_unicode_ci,
  `returned_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `loans_user_id_foreign` (`user_id`),
  CONSTRAINT `loans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loans`
--

LOCK TABLES `loans` WRITE;
/*!40000 ALTER TABLE `loans` DISABLE KEYS */;
INSERT INTO `loans` VALUES ('REQ-2026-0825-002',1,'Irfan Maulana, S.Kom','Seksi Data & Informasi Kesejahteraan Sosial','5','Yamaha NMAX 155 ABS','Diskominfo Pemprov Jawa Timur','Jl. A. Yani No. 242-244, Surabaya','Koordinasi integrasi server aplikasi SIP-K ke data center Diskominfo Jatim.','2026-08-25 00:00:00','2026-08-25 00:00:00','005/1310/107.5/2026',NULL,'selesai','2026-08-24 11:00:00','ND-5472/DINSOS/2026',NULL,19800,'3/4 (75%)','Lengkap dengan jas hujan dinas dan 2 buah helm.','2026-08-25 17:30:00','2026-09-22 21:40:30','2026-09-22 21:40:30'),('REQ-2026-0828-004',1,'Agus Setiawan, A.Md','Subbag Keuangan & Aset','1','Toyota Innova Reborn 2.4 G','Badan Pengelola Keuangan dan Aset Daerah (BPKAD) Jatim','Jl. Johar No. 17, Surabaya','Penyerahan SPJ dan rekonsiliasi data inventarisasi barang milik daerah.','2026-08-28 00:00:00','2026-08-29 00:00:00','005/1350/107.4.2/2026',NULL,'selesai','2026-08-27 14:20:00','ND-5490/DINSOS/2026',NULL,45200,'Full (100%)','Kondisi kendaraan bersih, toolkit lengkap, tidak ada kendala mesin.','2026-08-29 16:00:00','2026-09-22 21:40:30','2026-09-22 21:40:30'),('REQ-2026-0831-010',1,'Bambang Triyono, S.ST','Bidang Perlindungan & Jaminan Sosial (Linjamsos)','3','Isuzu Elf Minibus Dinsos Jatim','Penyaluran Bantuan Satgas Tagana Kab. Bojonegoro','Kompleks Pemkab & Gudang Logistik Dinsos Bojonegoro','Dropping logistik darurat bencana dan logistik dapur umum satgas Tagana.','2026-09-01 00:00:00','2026-09-04 00:00:00','005/1398/107.3/2026',NULL,'digunakan','2026-08-31 10:00:00','ND-5512/DINSOS/2026',NULL,NULL,NULL,NULL,NULL,'2026-09-22 21:40:30','2026-09-22 21:40:30'),('REQ-2026-0901-008',1,'Nurul Hidayati, M.Si','Bidang Rehabilitasi Sosial (Rehsos)','2','Toyota Avanza 1.3 Veloz','Monev UPT PRSPA Magetan & Ponorogo','Jl. Pahlawan No. 45, Magetan','Monitoring dan evaluasi pembinaan klien rehabilitasi sosial anak.','2026-09-01 00:00:00','2026-09-03 00:00:00','005/1405/107.1/2026',NULL,'disetujui','2026-09-01 07:45:00','ND-5519/DINSOS/2026',NULL,NULL,NULL,NULL,NULL,'2026-09-22 21:40:30','2026-09-22 21:40:30'),('REQ-2026-0902-001',1,'Rendy Cahyono Putra','Subbag Penyusunan Program & Anggaran','1','Toyota Innova Reborn 2.4 G','Bakorwil III Malang & UPT Dinsos Lawang','Jl. Raya Singosari No. 120, Malang','Koordinasi evaluasi program bantuan sosial kuartal 3 dan monitoring sarana prasarana.','2026-09-03 00:00:00','2026-09-05 00:00:00','005/1422/107.4.1/2026',NULL,'menunggu','2026-09-02 08:30:00',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-22 21:40:30','2026-09-22 21:40:30'),('REQ-2026-0902-002',1,'Dewi Sekar Arum, S.Sos','Bidang Penanganan Fakir Miskin (PFM)','4','Honda Vario 160 CBS','Bappeda Provinsi Jawa Timur','Jl. Pahlawan No. 110, Surabaya','Rapat koordinasi verifikasi dan validasi data DTKS terpadu.','2026-09-03 00:00:00','2026-09-03 00:00:00','005/1429/107.2.2/2026',NULL,'menunggu','2026-09-02 09:15:00',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-22 21:40:30','2026-09-22 21:40:30');
/*!40000 ALTER TABLE `loans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_09_15_000001_create_vehicles_table',1),(5,'2026_09_15_000002_create_loans_table',1),(6,'2026_09_15_000003_create_app_notifications_table',1),(7,'2026_09_15_141251_create_personal_access_tokens_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pegawai',
  `position` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` text COLLATE utf8mb4_unicode_ci,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_nip_unique` (`nip`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Rendy Cahyono Putra','19980512 202401 1 002','rendy@dinsos.jatimprov.go.id','pegawai','Staf Fungsional Perencana','Subbag Penyusunan Program & Anggaran','0812-3456-7890',NULL,NULL,NULL,'$2y$12$ms.C5t/yiiSgqloVaG3VLu.xzjMKAOvjQd25I4tkOtt6eOLUK03di',NULL,'2026-09-22 21:40:29','2026-09-22 21:40:29'),(2,'Ahmad Dewantara, S.STP','19850315 201001 1 003','admin@dinsos.jatimprov.go.id','admin','Kasubag Tata Usaha & Rumah Tangga','Bagian Tata Usaha','0812-9876-5432',NULL,NULL,NULL,'$2y$12$SiSzJ/6GRO9nZnQPQHzqjeHJOEXrFhjgv2jFC/jeX95Q.DbYta4yu',NULL,'2026-09-22 21:40:29','2026-09-22 21:40:29'),(3,'Super Admin SIP-K','19800101 200501 1 001','superadmin@dinsos.jatimprov.go.id','superadmin','Administrator Utama Sistem & Aset','Subbag Umum & Kepegawaian','0811-2233-4455',NULL,NULL,NULL,'$2y$12$FbqFvB84owldgPv6FfYz/eWqmH6xoaOu6VCpqqgSSv7x3g9Hmfnwu',NULL,'2026-09-22 21:40:30','2026-09-22 21:40:30'),(4,'Alamsyah','199503152020121002','alamsyah@dinsos.jatimprov.go.id','pegawai','Staf Pelaksana','Dinas Sosial Jawa Timur','0812-3456-7890',NULL,NULL,NULL,'$2y$12$kPcPbFFL57Oe4GOoW0i.QegT7rp774NL/dziNfL9c04rgHfpSspsC',NULL,'2026-09-23 00:23:01','2026-09-23 00:23:01');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `brand` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'mobil',
  `capacity` int NOT NULL DEFAULT '4',
  `transmission` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Manual',
  `current_odometer` int NOT NULL DEFAULT '0',
  `fuel_percent` int NOT NULL DEFAULT '100',
  `fuel_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Bensin',
  `condition_note` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'tersedia',
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gallery_images` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,'Toyota Innova Reborn 2.4 G','Toyota','L 1120 DP','Hitam Metalik','mobil',7,'Automatic',45200,100,'Dexlite / Solar Subsidi','Kondisi mesin sangat prima, AC dingin ganda, service rutin berkala di Auto2000.','tersedia','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30'),(2,'Toyota Avanza 1.3 Veloz','Toyota','L 1455 EP','Silver','mobil',7,'Manual',62100,75,'Pertalite / Pertamax','Kondisi mesin terawat, body mulus, rem baru diservis, kelengkapan surat lengkap.','tersedia','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30'),(3,'Isuzu Elf Minibus Dinsos Jatim','Isuzu','L 7002 AP','Putih Kombinasi Biru','mobil',16,'Manual',89400,50,'Solar Subsidi / Dexlite','Khusus penugasan rombongan satgas linjamsos & dropping logistik sosial.','digunakan','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30'),(4,'Honda Vario 160 CBS','Honda','L 3341 DS','Hitam Doff','motor',2,'Matic',14200,100,'Pertamax','Unit responsif dan lincah, khusus kurir dokumen dan dinas dalam kota Surabaya.','tersedia','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30'),(5,'Yamaha NMAX 155 ABS','Yamaha','L 4910 OS','Abu-Abu Doff','motor',2,'Matic',19800,80,'Pertamax','Kondisi ban depan belakang baru, rem ABS responsif, bagasi lega untuk jas hujan dan helm.','tersedia','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30'),(6,'Honda Supra X 125 Helm-in','Honda','L 2108 PS','Merah Hitam','motor',2,'Semi-Manual',31500,90,'Pertalite','Sangat irit bahan bakar, cocok untuk tugas operasional kurir surat dinas harian.','tersedia','assets/images/logo_sipk.png','[\"assets/images/logo_sipk.png\"]','2026-09-22 21:40:30','2026-09-22 21:40:30');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-23 15:00:57
