<?php
header('Content-Type: application/json');
require 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'], '/'));


function getSortClause($allowedFields) {
    $sortFields = [];
    if (isset($_GET['sort_by']) && is_array($_GET['sort_by'])) {
        foreach ($_GET['sort_by'] as $key => $field) {
            if (in_array($field, $allowedFields)) {
                $direction = (isset($_GET['sort_dir'][$key]) && strtolower($_GET['sort_dir'][$key]) == 'desc') ? 'DESC' : 'ASC';
                $sortFields[] = "$field $direction";
            }
        }
    } elseif (isset($_GET['sort_by'])) {
        $field = $_GET['sort_by'];
        if (in_array($field, $allowedFields)) {
            $direction = (isset($_GET['sort_dir']) && strtolower($_GET['sort_dir']) == 'desc') ? 'DESC' : 'ASC';
            $sortFields[] = "$field $direction";
        }
    }

    return !empty($sortFields) ? ' ORDER BY ' . implode(', ', $sortFields) : '';
}
// API untuk Barang
if ($request[0] == 'barang') {
    switch ($method) {
        case 'GET':
            $sql = "SELECT * FROM Barang";
            if (isset($request[1])) {
                $sql .= " WHERE IdBarang = " . intval($request[1]);
            } elseif (!empty($_GET['search'])) {
                $search = $conn->real_escape_string($_GET['search']);
                $sql .= " WHERE NamaBarang LIKE '%$search%' OR JenisBarang LIKE '%$search%'";
            }
             $sql .= getSortClause(['IdBarang', 'NamaBarang', 'JenisBarang']);
            $result = $conn->query($sql);
            $data = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode($data);
            break;

        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            $sql = "INSERT INTO Barang (NamaBarang, JenisBarang,StockAwal) VALUES ('" . $input['NamaBarang'] . "', '" . $input['JenisBarang'] . "','" . $input['StockAwal'] . "')";
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Barang berhasil ditambahkan"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            $sql = "UPDATE Barang SET NamaBarang='" . $input['NamaBarang'] . "', JenisBarang='" . $input['JenisBarang'] . "', StockAwal='" . $input['StockAwal'] . "' WHERE IdBarang=" . intval($request[1]);
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Barang berhasil diperbarui"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        case 'DELETE':
            $sql = "DELETE FROM Barang WHERE IdBarang=" . intval($request[1]);
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Barang berhasil dihapus"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        default:
            echo json_encode(["message" => "Metode tidak didukung"]);
            break;
    }
}

// API untuk Transaksi
if ($request[0] == 'transaksi') {
    switch ($method) {
        case 'GET':
           $sql = "SELECT IdTransaksi,Barang.IdBarang,NamaBarang, Stock,JumlahTerjual,TanggalTransaksi,JenisBarang
                    FROM Transaksi 
                    JOIN Barang ON Barang.IdBarang = Transaksi.IdBarang";

            if (isset($request[1])) {
                $sql .= " WHERE IdTransaksi = " . intval($request[1]);
            } elseif (isset($_GET['search'])) {
                $search = $conn->real_escape_string($_GET['search']);
                $sql .= " WHERE NamaBarang LIKE '%$search%' OR JenisBarang LIKE '%$search%'";
            }
            $sql .= getSortClause(['TanggalTransaksi', 'NamaBarang', 'JenisBarang']);

            $result = $conn->query($sql);

            $data = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode($data);
            break;
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            $sql = "INSERT INTO Transaksi (IdBarang, Stock, JumlahTerjual, TanggalTransaksi) VALUES (" . $input['IdBarang'] . ", " . $input['Stock'] . ", " . $input['JumlahTerjual'] . ", '" . $input['TanggalTransaksi'] . "')";
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Transaksi berhasil ditambahkan"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        case 'PUT':
            $input = json_decode(file_get_contents('php://input'), true);
            $sql = "UPDATE Transaksi SET IdBarang=" . $input['IdBarang'] . ", Stock=" . $input['Stock'] . ", JumlahTerjual=" . $input['JumlahTerjual'] . ", TanggalTransaksi='" . $input['TanggalTransaksi'] . "' WHERE IdTransaksi=" . intval($request[1]);
            // var_dump($sql);die;
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Transaksi berhasil diperbarui"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        case 'DELETE':
            $sql = "DELETE FROM Transaksi WHERE IdTransaksi=" . intval($request[1]);
            // var_dump($sql);die;
            if ($conn->query($sql) === TRUE) {
                echo json_encode(["message" => "Transaksi berhasil dihapus"]);
            } else {
                echo json_encode(["message" => "Error: " . $conn->error]);
            }
            break;

        default:
            echo json_encode(["message" => "Metode tidak didukung"]);
            break;
    }
}

if ($request[0] == 'compare') {
    switch ($method) {
        case 'GET':
            $sql = "SELECT JenisBarang, SUM(JumlahTerjual) as TotalTerjual
                    FROM Transaksi 
                    JOIN Barang ON Barang.IdBarang = Transaksi.IdBarang
                    WHERE 1=1"; 

            // Filter rentang waktu jika parameter diberikan
            if (isset($_GET['start_date']) && isset($_GET['end_date'])) {
                $start_date = $conn->real_escape_string($_GET['start_date']);
                $end_date = $conn->real_escape_string($_GET['end_date']);
                $sql .= " AND TanggalTransaksi BETWEEN '$start_date' AND '$end_date'";
            }

            // Grouping dan Sorting hasil
            $sql .= " GROUP BY JenisBarang";

            if (isset($_GET['order']) && strtolower($_GET['order']) == 'asc') {
                $sql .= " ORDER BY TotalTerjual ASC";
            } else {
                $sql .= " ORDER BY TotalTerjual DESC";
            }

            // Eksekusi query
            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
                $data = $result->fetch_all(MYSQLI_ASSOC);
                echo json_encode($data);
            } else {
                echo json_encode($data);
            }
            break;

        default:
            echo json_encode(["message" => "Metode tidak didukung"]);
            break;
    }
}

$conn->close();
?>
