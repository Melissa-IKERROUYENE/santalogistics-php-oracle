<?php
	require_once __DIR__ . '/includes/bootstrap.php';
    // Inclusion des paramètres de connexion
    include_once("connexion-base/connex.inc.php");

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="css/style-of-my-web-site-nav.css">
    <link rel="stylesheet" type="text/css" href="css/style-of-my-web-site-cust-index.css">
    <link rel="icon" type="image/x-icon" href="images/icons/icon.png">
    <title>SantaLogistics</title>
</head>
<?php
	// Inclusion de l'en-tête
	include("includes/cust-header.php");
	include('includes/functions.php');
?>


<main>
    <!-- Listes de souhaits ----------------------------------------------------------------------------------------------------->
    <div id="listes_souhaits" class="home-container">
        <div class="inner1-home-container">
            <div class="sep2"></div>
            <h2>Listes de souhaits</h2>
		    <p>Bienvenue, !</p>
		    <p>Créez votre liste de souhaits personnalisées.</p>

		    <form method="post" action="">
<?php echo csrfField(); ?>
				<!-- Champ pour l'identifiant de l'enfant -->
				<label for="id_enfant">ID Enfant:</label>
				<input type="text" id="id_enfant" name="id_enfant" maxlength="8" placeholder="ID Enfant" required>

				<!-- Champ pour le nom de l'enfant -->
				<label for="nom_enfant">Nom de l'enfant:</label>
				<input type="text" id="nom_enfant" name="nom_enfant" maxlength="50" placeholder="Nom de l'enfant" required>

				<!-- Champ pour le prénom de l'enfant -->
				<label for="prenom_enfant">Prénom de l'enfant:</label>
				<input type="text" id="prenom_enfant" name="prenom_enfant" maxlength="50" placeholder="Prénom de l'enfant" required>

				<!-- Champ pour l'adresse de l'enfant -->
				<label for="adresse">Adresse:</label>
				<input type="text" id="adresse" name="adresse" maxlength="50" placeholder="Adresse" required>


				<?php if (!empty($results)): ?>
						<?php foreach ($results as $row): ?>
							<div class="gift-item">
								<!-- Case à cocher pour sélectionner le cadeau -->
								<input type="checkbox" name="cadeaux_selectionnes[]" value="<?php echo htmlspecialchars($row['ID_JOUET']); ?>">
								<!-- Image et nom du jouet -->
								<img src="images/img/<?php echo htmlspecialchars($row['NOM_JOUET']); ?>.jpg" alt="<?php echo htmlspecialchars($row['NOM_JOUET']); ?>">
								<p class="gift-name"><?php echo htmlspecialchars($row['NOM_JOUET']); ?></p>
							</div>
						<?php endforeach; ?>
				<?php else: ?>
					<p>Aucun cadeau disponible pour le moment.</p>
				<?php endif; ?>

				<button type="submit" name="envoyer">Envoyer</button>
		    </form>
		<?php
		        if (isset($_SESSION['message'] )){
		            echo $_SESSION['message'];
		            unset($_SESSION['message']);
		        }
                ?>

			<?php
                // Une liste est enregistrée entièrement, ou aucune modification n'est conservée.
                if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['envoyer'])) {
                    $idconn = null;
                    try {
                        $values = [];
                        foreach (['id_enfant' => 8, 'nom_enfant' => 50, 'prenom_enfant' => 50, 'adresse' => 50] as $field => $limit) {
                            $value = $_POST[$field] ?? '';
                            if (!is_string($value) || trim($value) === '' || strlen($value) > $limit) {
                                throw new RuntimeException('Vérifiez les informations de l’enfant et la longueur des champs.');
                            }
                            $values[$field] = trim($value);
                        }
                        $selected = $_POST['cadeaux_selectionnes'] ?? [];
                        if (!is_array($selected) || !$selected) {
                            throw new RuntimeException('Sélectionnez au moins un jouet.');
                        }
                        foreach ($selected as $toy) {
                            if (!is_string($toy) || trim($toy) === '' || strlen(trim($toy)) > 8) {
                                throw new RuntimeException('Sélection de jouets invalide.');
                            }
                        }
                        $selected = array_unique(array_map('trim', $selected));
                        $idconn = connexoci();
                        $id = $values['id_enfant'];
                        // Verrouiller un enfant existant durant l'enregistrement de sa liste.
                        $stmt = oci_parse($idconn, 'SELECT id_enfant FROM les_enfants WHERE RTRIM(id_enfant) = :id FOR UPDATE');
                        oci_bind_by_name($stmt, ':id', $id);
                        if (!oci_execute($stmt, OCI_NO_AUTO_COMMIT)) { throw new RuntimeException('Impossible de vérifier l’enfant.'); }
                        $exists = oci_fetch_assoc($stmt);
                        oci_free_statement($stmt);
                        if (!$exists) {
                            $stmt = oci_parse($idconn, 'INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES (:id, :nom, :prenom, :adresse)');
                            oci_bind_by_name($stmt, ':id', $id);
                            oci_bind_by_name($stmt, ':nom', $values['nom_enfant']);
                            oci_bind_by_name($stmt, ':prenom', $values['prenom_enfant']);
                            oci_bind_by_name($stmt, ':adresse', $values['adresse']);
                            if (!oci_execute($stmt, OCI_NO_AUTO_COMMIT)) { throw new RuntimeException('Impossible d’enregistrer l’enfant.'); }
                            oci_free_statement($stmt);
                        }
                        $stmt = oci_parse($idconn, 'SELECT COUNT(*) AS TOTAL FROM commande_jouets WHERE RTRIM(id_enfant) = :id');
                        oci_bind_by_name($stmt, ':id', $id);
                        if (!oci_execute($stmt, OCI_NO_AUTO_COMMIT)) { throw new RuntimeException('Impossible de vérifier la liste.'); }
                        $row = oci_fetch_assoc($stmt);
                        oci_free_statement($stmt);
                        if ($row['TOTAL'] > 0) { throw new RuntimeException('Une liste a déjà été enregistrée pour cet enfant.'); }
                        $stmt = oci_parse($idconn, 'INSERT INTO commande_jouets (id_enfant, id_jouet, date_commande) VALUES (:id, :jouet, TRUNC(SYSDATE))');
                        oci_bind_by_name($stmt, ':id', $id);
                        foreach ($selected as $toy) {
                            oci_bind_by_name($stmt, ':jouet', $toy);
                            if (!oci_execute($stmt, OCI_NO_AUTO_COMMIT)) { throw new RuntimeException('Impossible d’enregistrer les jouets sélectionnés. Aucun changement conservé.'); }
                        }
                        oci_free_statement($stmt);
                        if (!oci_commit($idconn)) { throw new RuntimeException('Impossible de valider la liste.'); }
                        oci_close($idconn);
                        $_SESSION['message'] = '<div class="success">Votre liste de souhaits a été enregistrée.</div>';
                        header('Location: listes_souhaits.php');
                        exit;
                    } catch (RuntimeException $e) {
                        if ($idconn) { oci_rollback($idconn); oci_close($idconn); }
                        echo '<div class="error">' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . '</div>';
                    }
                }
            ?>
        </div>
    </div>
</main>

<?php
// Inclusion du pied de page
include("includes/cust-footer.php");
?>
