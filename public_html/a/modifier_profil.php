<?php
    require_once __DIR__ . '/../includes/auth.php';
    // Inclusion des paramètres de connexion
    include_once("../connexion-base/connex.inc.php");
    // Vérifier si l'utilisateur est connecté
    if (!isset($_SESSION['user_id'])) {
        header('Location: compte.php');
        exit();
    }

    // Seuls ces champs de profil peuvent être modifiés.
    $champ = $_POST['champ'] ?? $_GET['champ'] ?? '';
    if (!in_array($champ, ['NOM', 'PRENOM', 'LOGIN', 'PASSWORD'], true)) {
        http_response_code(400);
        exit('Champ de profil invalide.');
    }
    // Connexion à la base de données Oracle
    $idconn = connexoci("my-param", "oracle2");

    // Vérifier si le formulaire a été soumis
    if ($_SERVER['REQUEST_METHOD'] === 'POST' ) {
        // Récupérer les données du formulaire
        // Champ déjà validé par la liste autorisée.
        $nouvelle_valeur = (string)($_POST['nouvelle_valeur'] ?? '');
        if ($champ == "PASSWORD"){
            $confirm_password = (string)($_POST['nouvelle_valeurconfirmation'] ?? '');
            if (strlen($nouvelle_valeur) < 8 || strlen($nouvelle_valeur) > 64 || $nouvelle_valeur !== $confirm_password) {
                // Vérification que les mots de passe correspondent
                echo "<div class='error'>Utilisez deux mots de passe identiques de 8 à 64 caractères.</div>";
                exit();
            }
        }
        if ($champ === 'PASSWORD') { $nouvelle_valeur = password_hash($nouvelle_valeur, PASSWORD_BCRYPT); }
        $id_lutin = $_SESSION['user_id'];
        // Préparer la requête SQL pour mettre à jour le champ spécifié
        $requete = "UPDATE lutins SET $champ = :nouvelle_valeur WHERE RTRIM(id_lutin) = RTRIM(:id_lutin)";
        $stmt = oci_parse($idconn, $requete);
        oci_bind_by_name($stmt, ":nouvelle_valeur", $nouvelle_valeur);
        oci_bind_by_name($stmt, ":id_lutin", $id_lutin);

        // Exécuter la requête
        if (oci_execute($stmt)) {
            $_SESSION['message'] = "<div class='success'>Le champ $champ a été mis à jour avec succès.</div>";
        } else {
            $_SESSION['message'] = "<div class='error'>Erreur lors de la mise à jour du champ $champ.</div>";
        }

        oci_free_statement($stmt);
        // Rediriger l'utilisateur vers la page de profil
        header('Location: compte.php');
        exit();
    }

    // Fermer la connexion à la base de données
    oci_close($idconn);
    
// Si le formulaire n'a pas été soumis, afficher le formulaire de modification
// $champ a déjà été validé.
?>


<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="../css/style-of-my-web-site-nav.css">
    <link rel="stylesheet" type="text/css" href="../css/style-of-my-web-site-admi-windows.css">
    <link rel="icon" type="image/x-icon" href="../images/icons/icon.png">
    <title>SantaLogistics</title>
</head>
<?php
    // Inclusion de l'en-tête
    include("../includes/administrator-header.php");
?>

<main>
    <h1>Modifier <?php echo htmlspecialchars($champ); ?></h1>
    <?php if ($champ!="PASSWORD"){?>
    <form method="POST" action="modifier_profil.php">
<?php echo csrfField(); ?>
        <input type="hidden" name="champ" value="<?php echo htmlspecialchars($champ); ?>">
        <label for="nouvelle_valeur">Nouvelle valeur :</label>
        <input type="text" id="nouvelle_valeur" name="nouvelle_valeur" required>
        <button type="submit">Mettre à jour</button>
    </form>
    <?php }else { ?>
        <form method="POST" action="modifier_profil.php">
<?php echo csrfField(); ?>
        <input type="hidden" name="champ" value="<?php echo htmlspecialchars($champ); ?>">
        <label for="nouvelle_valeur">Nouveau mot de passe :</label>
        <input type="password" id="nouvelle_valeur" name="nouvelle_valeur" maxlength="64" required></div>
        <div><label for="confirm_password">Confirmez le mot de passe :</label>
        <input type="password" id="nouvelle_valeur" name="nouvelle_valeurconfirmation" maxlength="64" required></div>
        <button type="submit">Mettre à jour</button>
    </form>
    <?php } ?>
    <p><a href="compte.php">Retour</a></p>
    </main>
<?php
// Inclusion du pied de page
include("../includes/administrator-footer.php");
?>
