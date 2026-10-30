<?php
require_once __DIR__ . '/bootstrap.php';
if (empty($_SESSION['user_id'])) {
    header('Location: compte.php');
    exit;
}
