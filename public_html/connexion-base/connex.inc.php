<?php
function santaConfig()
{
    static $config = null;
    if ($config === null) {
        $file = dirname(__DIR__, 2) . '/config.local.php';
        $config = is_file($file) ? require $file : [];
        if (!is_array($config)) { $config = []; }
        // Compatibilité avec l'installation d'origine : ce fichier reste privé.
        $legacy = __DIR__ . '/my-param.inc.php';
        if (!is_file($file) && is_file($legacy)) {
            require_once $legacy;
            foreach (['host' => 'MYHOST', 'user' => 'MYUSER', 'password' => 'MYPASS'] as $key => $constant) {
                if (defined($constant)) { $config[$key] = constant($constant); }
            }
        }
        foreach (['host' => 'ORACLE_HOST', 'user' => 'ORACLE_USER',
                  'password' => 'ORACLE_PASSWORD', 'registration_code' => 'SANTA_REGISTRATION_CODE'] as $key => $env) {
            $value = getenv($env);
            if ($value !== false) { $config[$key] = $value; }
        }
    }
    return $config;
}

// Signature conservée pour les pages existantes.
function connexoci($param = 'my-param', $base = 'oracle')
{
    if (!extension_loaded('oci8')) {
        http_response_code(503);
        exit('Extension PHP OCI8 manquante. Consultez les prérequis du README.');
    }
    $config = santaConfig();
    foreach (['host', 'user', 'password'] as $key) {
        if (empty($config[$key])) {
            http_response_code(503);
            exit('Connexion Oracle non configurée. Complétez config.local.php à partir de config.example.php.');
        }
    }
    $conn = @oci_connect($config['user'], $config['password'], $config['host'], 'AL32UTF8');
    if (!$conn) {
        $error = oci_error();
        error_log('SantaLogistics Oracle: ' . ($error['message'] ?? 'connexion impossible'));
        http_response_code(503);
        exit('Connexion Oracle impossible. Vérifiez le service, les identifiants et la disponibilité de la base.');
    }
    return $conn;
}
