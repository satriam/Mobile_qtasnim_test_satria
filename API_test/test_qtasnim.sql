-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 15, 2024 at 05:09 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `test_qtasnim`
--

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `IdBarang` int(11) NOT NULL,
  `NamaBarang` varchar(50) NOT NULL,
  `JenisBarang` enum('Konsumsi','Pembersih') NOT NULL,
  `StockAwal` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`IdBarang`, `NamaBarang`, `JenisBarang`, `StockAwal`) VALUES
(1, 'Kopi', 'Konsumsi', 75),
(2, 'Teh', 'Konsumsi', 76),
(3, 'Pasta Gigi', 'Pembersih', 80),
(4, 'Sabun Mandi', 'Pembersih', 70),
(5, 'Sampo', 'Pembersih', 75);

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `IdTransaksi` int(11) NOT NULL,
  `IdBarang` int(11) NOT NULL,
  `JumlahTerjual` int(11) NOT NULL,
  `Stock` int(11) DEFAULT NULL,
  `TanggalTransaksi` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`IdTransaksi`, `IdBarang`, `JumlahTerjual`, `Stock`, `TanggalTransaksi`) VALUES
(22, 1, 10, 100, '2021-05-01'),
(23, 2, 19, 100, '2021-05-05'),
(24, 1, 15, 90, '2021-05-10'),
(25, 3, 20, 100, '2021-05-11'),
(26, 4, 30, 100, '2021-05-11'),
(27, 5, 25, 100, '2021-05-12'),
(28, 2, 5, 81, '2021-05-12');

--
-- Triggers `transaksi`
--
DELIMITER $$
CREATE TRIGGER `Pengurangan_stock_transaksi` AFTER INSERT ON `transaksi` FOR EACH ROW BEGIN
    UPDATE barang
    SET StockAwal = StockAwal - NEW.JumlahTerjual
    WHERE IdBarang = NEW.IdBarang;
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_adjust_stock_after_update` AFTER UPDATE ON `transaksi` FOR EACH ROW BEGIN
    DECLARE stock_difference INT;
    SET stock_difference = OLD.JumlahTerjual - NEW.JumlahTerjual;

    UPDATE Barang
    SET StockAwal = StockAwal + stock_difference
    WHERE IdBarang = NEW.IdBarang;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_revert_stock_after_delete` AFTER DELETE ON `transaksi` FOR EACH ROW BEGIN
    UPDATE Barang
    SET StockAwal = StockAwal + OLD.JumlahTerjual
    WHERE IdBarang = OLD.IdBarang;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`IdBarang`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`IdTransaksi`),
  ADD KEY `transaksi` (`IdBarang`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `barang`
--
ALTER TABLE `barang`
  MODIFY `IdBarang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `IdTransaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi` FOREIGN KEY (`IdBarang`) REFERENCES `barang` (`IdBarang`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
