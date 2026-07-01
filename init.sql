-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 23, 2026 at 11:38 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_campus`
--

-- --------------------------------------------------------

--
-- Table structure for table `appeal`
--

CREATE TABLE `appeal` (
  `appeal_id` varchar(10) NOT NULL,
  `summons_id` varchar(10) NOT NULL,
  `student_id` varchar(10) NOT NULL,
  `appeal_reason` varchar(500) NOT NULL,
  `status` enum('PENDING','REASONABLE','MODERATELY_REASONABLE','UNREASONABLE') NOT NULL DEFAULT 'PENDING',
  `clerical_comment` varchar(500) DEFAULT NULL,
  `reviewed_by` varchar(10) DEFAULT NULL,
  `appeal_date` date NOT NULL,
  `reviewed_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appeal`
--

INSERT INTO `appeal` (`appeal_id`, `summons_id`, `student_id`, `appeal_reason`, `status`, `clerical_comment`, `reviewed_by`, `appeal_date`, `reviewed_date`, `created_at`, `updated_at`) VALUES
('APP001', 'SUM001', 'STU0006', 'saya nak mohon kurangkan harga', 'MODERATELY_REASONABLE', '', 'CL001', '2026-05-14', '2026-05-14', '2026-05-14 06:46:43', '2026-05-19 15:14:59'),
('APP002', 'SUM006', 'STU0006', 'Saya first time merokok', 'UNREASONABLE', 'Merokok Adalah Kesalahan Mandatory', 'CL002', '2026-05-19', '2026-05-19', '2026-05-19 13:58:34', '2026-05-19 15:16:28'),
('APP003', 'SUM007', 'STU0006', 'kkddkkddkdkkddkdkdkdk', 'REASONABLE', '', 'CL002', '2026-05-20', '2026-05-20', '2026-05-19 16:58:05', '2026-05-19 16:58:45'),
('APP004', 'SUM018', 'STU0006', 'Saya Parking pada tempat yang betul', 'MODERATELY_REASONABLE', 'Test', 'CL002', '2026-05-20', '2026-05-20', '2026-05-20 07:35:01', '2026-05-20 07:35:45'),
('APP005', 'SUM022', 'STU0006', 'Saya Terlupa sebab saya terkejar kejar', 'MODERATELY_REASONABLE', '', 'CL001', '2026-06-08', '2026-06-08', '2026-06-08 15:08:07', '2026-06-08 15:08:47'),
('APP006', 'SUM023', 'STU0006', 'Helmet saya kene curi ketika parking', 'REASONABLE', '', 'CL002', '2026-06-08', '2026-06-09', '2026-06-08 15:59:37', '2026-06-08 16:00:18'),
('APP007', 'SUM024', 'STU0007', 'Minta maaf saya terlupa', 'MODERATELY_REASONABLE', '', 'CL002', '2026-06-09', '2026-06-09', '2026-06-08 16:01:58', '2026-06-08 16:02:30'),
('APP008', 'SUM025', 'STU0007', 'Saya terlalu rushing sampai terlupa', 'PENDING', NULL, NULL, '2026-06-09', NULL, '2026-06-08 17:37:48', NULL),
('APP010', 'SUM028', 'STU0010', 'Saya minta maaf sebab saya stress sebabtu saya merokok', 'MODERATELY_REASONABLE', 'Okey saya maafkan', 'CL002', '2026-06-09', '2026-06-09', '2026-06-09 03:24:57', '2026-06-09 03:26:24');

-- --------------------------------------------------------

--
-- Table structure for table `clerical_staff`
--

CREATE TABLE `clerical_staff` (
  `clerical_staff_id` varchar(10) NOT NULL,
  `clerical_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clerical_staff`
--

INSERT INTO `clerical_staff` (`clerical_staff_id`, `clerical_name`, `email`, `phone_number`, `password`) VALUES
('CL001', 'Nur Aina', 'aina@ocean.umt.edu.my', '0123456789', 'aina123'),
('CL002', 'Farhan', 'farhan@ocean.umt.edu.my', '0112222333', 'farhan123');

-- --------------------------------------------------------

--
-- Table structure for table `patrolstaff`
--

CREATE TABLE `patrolstaff` (
  `patrolStaffID` varchar(255) NOT NULL,
  `patrolName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phoneNumber` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patrolstaff`
--

INSERT INTO `patrolstaff` (`patrolStaffID`, `patrolName`, `email`, `phoneNumber`, `password`) VALUES
('PAT001', 'Ahmad Firdaus', 'firdaus@ocean.umt.edu.my', '0111234567', 'pat123'),
('PAT002', 'Siti Nora', 'nora@ocean.umt.edu.my', '0119876543', 'pat123');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` varchar(10) NOT NULL,
  `summons_id` varchar(10) NOT NULL,
  `payment_method` enum('ONLINE','OFFICE') NOT NULL,
  `payment_amount` double NOT NULL,
  `bank_card_no` varchar(20) DEFAULT NULL,
  `card_expiry` varchar(7) DEFAULT NULL,
  `cvv` varchar(3) DEFAULT NULL,
  `status` enum('PAID','PENDING_OFFICE') NOT NULL DEFAULT 'PAID',
  `payment_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `summons_id`, `payment_method`, `payment_amount`, `bank_card_no`, `card_expiry`, `cvv`, `status`, `payment_date`, `created_at`) VALUES
('PAY001', 'SUM002', 'ONLINE', 30, '1234559622336658', '06/27', NULL, 'PAID', '2026-04-15', '2026-04-14 21:09:55'),
('PAY002', 'SUM004', 'OFFICE', 40, NULL, NULL, NULL, 'PAID', '2026-04-23', '2026-04-23 07:17:54'),
('PAY003', 'SUM003', 'ONLINE', 50, '4559952223366655', '06/29', NULL, 'PAID', '2026-04-23', '2026-04-23 07:19:27'),
('PAY005', 'SUM001', 'ONLINE', 2, '1444555666665444', '04/28', NULL, 'PAID', '2026-05-14', '2026-05-14 07:34:23'),
('PAY006', 'SUM006', 'ONLINE', 50, '9885665878823323', '12/28', NULL, 'PAID', '2026-05-19', '2026-05-19 15:18:00'),
('PAY007', 'SUM005', 'OFFICE', 50, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-19 20:03:33'),
('PAY008', 'SUM008', 'OFFICE', 100, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-19 20:04:56'),
('PAY009', 'SUM009', 'ONLINE', 20, '4444444444444444', '07/29', NULL, 'PAID', '2026-05-20', '2026-05-19 21:25:30'),
('PAY010', 'SUM010', 'ONLINE', 40, '4744444444444444', '04/28', NULL, 'PAID', '2026-05-20', '2026-05-19 21:26:58'),
('PAY011', 'SUM011', 'ONLINE', 30, '7777777777777777', '01/29', NULL, 'PAID', '2026-05-20', '2026-05-19 21:28:25'),
('PAY012', 'SUM012', 'ONLINE', 20, '1111111111111111', '02/29', NULL, 'PAID', '2026-05-20', '2026-05-19 21:36:41'),
('PAY013', 'SUM013', 'ONLINE', 50, '1445223355777777', '02/29', NULL, 'PAID', '2026-05-20', '2026-05-19 21:44:04'),
('PAY014', 'SUM014', 'OFFICE', 20, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-19 21:52:14'),
('PAY018', 'SUM018', 'OFFICE', 20, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-20 07:36:05'),
('PAY019', 'SUM019', 'OFFICE', 30, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-20 07:41:23'),
('PAY020', 'SUM020', 'OFFICE', 20, NULL, NULL, NULL, 'PAID', '2026-05-20', '2026-05-20 08:02:05'),
('PAY021', 'SUM021', 'ONLINE', 30, '5256627727782882', '06/29', NULL, 'PAID', '2026-06-04', '2026-06-04 05:25:33'),
('PAY022', 'SUM022', 'ONLINE', 10, '1515166166146446', '06/29', NULL, 'PAID', '2026-06-08', '2026-06-08 15:09:15'),
('PAY024', 'SUM028', 'ONLINE', 10, '1533434343434343', '06/29', NULL, 'PAID', '2026-06-09', '2026-06-09 03:26:57'),
('PAY025', 'SUM029', 'ONLINE', 50, '4521424242422111', '04/32', NULL, 'PAID', '2026-06-09', '2026-06-09 03:44:36');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `student_id` varchar(10) NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `matric_no` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `faculty` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`student_id`, `student_name`, `matric_no`, `email`, `phone_number`, `faculty`, `password`) VALUES
('STU0006', 'Muhammad Shahrul Aiman Bin Mokhtar', 'S70611', 'S70611@ocean.umt.edu.my', '01172735439', 'FSKM', '1234'),
('STU0007', 'Ariiq Mustaqiim', 'S70799', 'S70799@ocean.umt.edu.my', '1234', 'FSKM', '1234'),
('STU0009', 'LIQMAN HAKIM BIN ABD RAHMAN', 'S76899', 'S76899@ocean.umt.edu.my', '01178952658', 'FPEPS', '1234'),
('STU0010', 'Muhammad Raziq Bin Md Zin', 'S70021', 's70021@ocean.umt.edu.my', '0196314526', 'FSKM', '1234'),
('STU0011', 'Muhammad Syafiq Bin Shaffie', 'S70741', 's70741@ocean.umt.edu.my', '0136698547', 'FSKM', '1234'),
('STU0012', 'Kamal Arif Bin Khalid Hasan', 'S71905', 's71905@ocean.umt.edu.my', '0123456789', 'FSKM', '1234');

-- --------------------------------------------------------

--
-- Table structure for table `student_offense_type`
--

CREATE TABLE `student_offense_type` (
  `offense_id` varchar(10) NOT NULL,
  `offense_name` varchar(255) NOT NULL,
  `offense_category` enum('MISCONDUCT','VEHICLE') NOT NULL,
  `amount` double NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_by` varchar(10) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_offense_type`
--

INSERT INTO `student_offense_type` (`offense_id`, `offense_name`, `offense_category`, `amount`, `description`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
('OFF001', 'Smoking', 'MISCONDUCT', 50, 'Student caught smoking in prohibited area', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF002', 'Not Wearing Matric Card', 'MISCONDUCT', 20, 'Student not wearing matric card in class or campus area', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF003', 'Inappropriate Attire', 'MISCONDUCT', 30, 'Student wearing inappropriate clothing on campus', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', '2026-06-08 20:12:23'),
('OFF004', 'Vandalism', 'MISCONDUCT', 100, 'Student caught damaging university property', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF005', 'Loitering', 'MISCONDUCT', 20, 'Student loitering in restricted area', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', '2026-04-09 06:49:16'),
('OFF006', 'Illegal Parking', 'VEHICLE', 50, 'Vehicle parked in unauthorized area', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF007', 'Speeding', 'VEHICLE', 100, 'Vehicle exceeding campus speed limit', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF008', 'Not Wearing Helmet', 'VEHICLE', 50, 'Motorcycle rider not wearing helmet on campus', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF009', 'No Parking Sticker', 'VEHICLE', 30, 'Vehicle without valid campus parking sticker', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL),
('OFF010', 'Wrong Parking Zone', 'VEHICLE', 40, 'Vehicle parked in wrong designated zone', 'ACTIVE', 'CL001', '2026-04-09 06:08:21', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `summons`
--

CREATE TABLE `summons` (
  `summons_id` varchar(10) NOT NULL,
  `summons_date` date NOT NULL,
  `summons_type` enum('VEHICLE','MISCONDUCT') NOT NULL,
  `offense_id` varchar(10) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `amount` double NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'UNPAID',
  `location` varchar(255) NOT NULL,
  `plate_number` varchar(20) DEFAULT NULL,
  `matric_no` varchar(20) DEFAULT NULL,
  `patrol_staff_id` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `summons`
--

INSERT INTO `summons` (`summons_id`, `summons_date`, `summons_type`, `offense_id`, `description`, `amount`, `status`, `location`, `plate_number`, `matric_no`, `patrol_staff_id`, `created_at`, `updated_at`) VALUES
('SUM001', '2026-04-15', 'VEHICLE', 'OFF009', '', 2, 'PAID', 'dpn cu mart', 'VHR1461', NULL, 'PAT001', '2026-04-14 20:18:18', '2026-05-14 07:34:23'),
('SUM002', '2026-04-15', 'MISCONDUCT', 'OFF003', '', 30, 'PAID', 'pism', NULL, 'S70611', 'PAT001', '2026-04-14 20:18:49', '2026-04-14 21:09:55'),
('SUM003', '2026-04-23', 'MISCONDUCT', 'OFF001', '', 50, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-04-23 06:40:50', '2026-04-23 07:19:27'),
('SUM004', '2026-04-23', 'VEHICLE', 'OFF010', '', 40, 'PAID', 'ks', 'VHR1461', NULL, 'PAT001', '2026-04-23 06:44:37', '2026-05-19 20:01:15'),
('SUM005', '2026-04-23', 'VEHICLE', 'OFF008', '', 50, 'PAID', 'PISM', 'VHR1461', NULL, 'PAT001', '2026-04-23 08:12:55', '2026-05-19 20:03:46'),
('SUM006', '2026-05-14', 'MISCONDUCT', 'OFF001', '', 50, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-05-14 07:27:39', '2026-05-19 15:18:00'),
('SUM007', '2026-05-19', 'VEHICLE', 'OFF010', 'SXWW', 40, 'WAIVED', 'pism', 'VHR1461', NULL, 'PAT001', '2026-05-19 15:21:25', '2026-05-19 16:58:45'),
('SUM008', '2026-05-20', 'MISCONDUCT', 'OFF004', 'haa merokok', 100, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-05-19 20:04:35', '2026-05-19 23:33:13'),
('SUM009', '2026-05-20', 'MISCONDUCT', 'OFF002', '', 20, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-05-19 21:24:33', '2026-05-19 21:25:30'),
('SUM010', '2026-05-20', 'VEHICLE', 'OFF010', '', 40, 'PAID', 'pism', 'VHR1461', NULL, 'PAT001', '2026-05-19 21:26:39', '2026-05-19 21:26:58'),
('SUM011', '2026-05-20', 'MISCONDUCT', 'OFF003', '', 30, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-05-19 21:27:56', '2026-05-19 21:28:25'),
('SUM012', '2026-05-20', 'MISCONDUCT', 'OFF005', '', 20, 'PAID', 'College', NULL, 'S70611', 'PAT001', '2026-05-19 21:36:22', '2026-05-19 21:36:41'),
('SUM013', '2026-05-20', 'VEHICLE', 'OFF008', '', 50, 'PAID', 'pism', 'VHR1461', NULL, 'PAT001', '2026-05-19 21:43:37', '2026-05-19 21:44:04'),
('SUM014', '2026-05-20', 'MISCONDUCT', 'OFF002', '', 20, 'PAID', 'ks', NULL, 'S70799', 'PAT001', '2026-05-19 21:51:58', '2026-05-19 21:52:54'),
('SUM015', '2026-05-20', 'MISCONDUCT', 'OFF001', '', 50, 'UNPAID', 'Dekat UMTCC', NULL, NULL, 'PAT001', '2026-05-19 21:55:31', '2026-06-09 04:44:36'),
('SUM016', '2026-05-20', 'MISCONDUCT', 'OFF004', '', 100, 'UNPAID', 'Dekat UMTCC', NULL, NULL, 'PAT001', '2026-05-19 22:35:08', '2026-06-09 04:45:11'),
('SUM017', '2026-05-20', 'MISCONDUCT', 'OFF002', 'test', 20, 'UNPAID', 'Dekat UMTCC', NULL, NULL, 'PAT002', '2026-05-20 07:30:09', '2026-06-09 04:45:25'),
('SUM018', '2026-05-20', 'VEHICLE', 'OFF010', 'TEST', 20, 'PAID', 'FSKM', 'VHR1461', NULL, 'PAT001', '2026-05-20 07:34:27', '2026-05-20 07:36:48'),
('SUM019', '2026-05-20', 'MISCONDUCT', 'OFF003', '', 30, 'PAID', 'ks', NULL, 'S70611', 'PAT001', '2026-05-20 07:41:01', '2026-05-20 07:41:44'),
('SUM020', '2026-05-20', 'MISCONDUCT', 'OFF002', '', 20, 'PAID', 'ks', NULL, 'S70611', 'PAT001', '2026-05-20 08:01:26', '2026-05-20 08:02:23'),
('SUM021', '2026-06-04', 'VEHICLE', 'OFF009', '', 30, 'PAID', 'FSKM', 'VHR1461', NULL, 'PAT001', '2026-06-04 05:24:37', '2026-06-04 05:25:33'),
('SUM022', '2026-06-08', 'MISCONDUCT', 'OFF002', '', 10, 'PAID', 'Perpustakaan Sultanah Nur Zahirah (PSNZ)', NULL, 'S70611', 'PAT001', '2026-06-08 15:07:31', '2026-06-08 15:09:15'),
('SUM023', '2026-06-08', 'VEHICLE', 'OFF010', '', 40, 'WAIVED', 'Parking Lot E - Pusat Asasi STEM (PASTEM)', 'VHR1461', NULL, 'PAT001', '2026-06-08 15:59:03', '2026-06-08 16:00:18'),
('SUM024', '2026-06-09', 'MISCONDUCT', 'OFF002', '', 12, 'UNPAID', 'Pusat Kesihatan Universiti (PKU)', NULL, 'S70799', 'PAT001', '2026-06-08 16:01:27', '2026-06-08 16:02:30'),
('SUM025', '2026-06-09', 'MISCONDUCT', 'OFF003', '', 30, 'APPEALED', 'Pusat Kesihatan Universiti (PKU)', NULL, 'S70799', 'PAT002', '2026-06-08 17:37:19', '2026-06-08 17:37:48'),
('SUM026', '2026-06-09', 'MISCONDUCT', 'OFF005', '', 20, 'UNPAID', 'Kompleks Siswa', NULL, 'S70611', 'PAT002', '2026-06-08 19:01:17', NULL),
('SUM027', '2026-06-09', 'MISCONDUCT', 'OFF001', '', 30, 'UNPAID', 'Kompleks Siswa', NULL, NULL, 'PAT002', '2026-06-08 19:44:07', '2026-06-09 04:46:45'),
('SUM028', '2026-06-09', 'MISCONDUCT', 'OFF001', '', 10, 'PAID', 'Perpustakaan Sultanah Nur Zahirah (PSNZ)', NULL, 'S70021', 'PAT001', '2026-06-09 03:24:16', '2026-06-09 03:26:57'),
('SUM029', '2026-06-09', 'MISCONDUCT', 'OFF001', '', 50, 'PAID', 'Kompleks Siswa', NULL, 'S71905', 'PAT002', '2026-06-09 03:44:15', '2026-06-09 03:44:36'),
('SUM030', '2026-06-09', 'VEHICLE', 'OFF009', '', 30, 'UNPAID', 'Parking Lot A - Fakulti Sains & Sekitaran Marin (FSSM)', 'VHR1461', NULL, 'PAT002', '2026-06-09 04:38:38', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE `vehicle` (
  `vehicle_id` varchar(10) NOT NULL,
  `student_id` varchar(10) NOT NULL,
  `vehicle_type` enum('CAR','MOTORCYCLE') NOT NULL,
  `plate_number` varchar(20) NOT NULL,
  `brand` varchar(50) NOT NULL,
  `color` varchar(30) NOT NULL,
  `engine_cc` varchar(10) NOT NULL,
  `grant_image_path` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `clerk_comment` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`vehicle_id`, `student_id`, `vehicle_type`, `plate_number`, `brand`, `color`, `engine_cc`, `grant_image_path`, `status`, `clerk_comment`, `created_at`, `updated_at`) VALUES
('VEH0001', 'STU0006', 'MOTORCYCLE', 'VHR1461', 'YAMAHA', 'Nescafe', '150', 'uploads/grants/GRANT_STU0006_1775721718352.jpeg', 'APPROVED', '', '2026-04-09 08:01:58', '2026-04-14 20:02:23'),
('VEH0002', 'STU0007', 'CAR', 'SYE4948', 'Perodua Axia', 'Red', '1.0', 'uploads/grants/GRANT_STU0007_1780956179085.jpg', 'APPROVED', '', '2026-06-08 22:02:59', '2026-06-08 22:03:47');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appeal`
--
ALTER TABLE `appeal`
  ADD PRIMARY KEY (`appeal_id`),
  ADD UNIQUE KEY `uq_summons_appeal` (`summons_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `reviewed_by` (`reviewed_by`);

--
-- Indexes for table `clerical_staff`
--
ALTER TABLE `clerical_staff`
  ADD PRIMARY KEY (`clerical_staff_id`),
  ADD UNIQUE KEY `uq_clerical_email` (`email`);

--
-- Indexes for table `patrolstaff`
--
ALTER TABLE `patrolstaff`
  ADD PRIMARY KEY (`patrolStaffID`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `summons_id` (`summons_id`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `matric_no` (`matric_no`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `student_offense_type`
--
ALTER TABLE `student_offense_type`
  ADD PRIMARY KEY (`offense_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `summons`
--
ALTER TABLE `summons`
  ADD PRIMARY KEY (`summons_id`),
  ADD KEY `offense_id` (`offense_id`),
  ADD KEY `plate_number` (`plate_number`),
  ADD KEY `matric_no` (`matric_no`),
  ADD KEY `patrol_staff_id` (`patrol_staff_id`);

--
-- Indexes for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD PRIMARY KEY (`vehicle_id`),
  ADD UNIQUE KEY `plate_number` (`plate_number`),
  ADD KEY `student_id` (`student_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appeal`
--
ALTER TABLE `appeal`
  ADD CONSTRAINT `appeal_ibfk_1` FOREIGN KEY (`summons_id`) REFERENCES `summons` (`summons_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appeal_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appeal_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `clerical_staff` (`clerical_staff_id`) ON DELETE SET NULL;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`summons_id`) REFERENCES `summons` (`summons_id`) ON DELETE CASCADE;

--
-- Constraints for table `student_offense_type`
--
ALTER TABLE `student_offense_type`
  ADD CONSTRAINT `student_offense_type_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `clerical_staff` (`clerical_staff_id`) ON DELETE CASCADE;

--
-- Constraints for table `summons`
--
ALTER TABLE `summons`
  ADD CONSTRAINT `summons_ibfk_1` FOREIGN KEY (`offense_id`) REFERENCES `student_offense_type` (`offense_id`),
  ADD CONSTRAINT `summons_ibfk_2` FOREIGN KEY (`plate_number`) REFERENCES `vehicle` (`plate_number`) ON DELETE SET NULL,
  ADD CONSTRAINT `summons_ibfk_3` FOREIGN KEY (`matric_no`) REFERENCES `student` (`matric_no`) ON DELETE SET NULL,
  ADD CONSTRAINT `summons_ibfk_4` FOREIGN KEY (`patrol_staff_id`) REFERENCES `patrolstaff` (`patrolStaffID`) ON DELETE CASCADE;

--
-- Constraints for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD CONSTRAINT `fk_vehicle_student` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
