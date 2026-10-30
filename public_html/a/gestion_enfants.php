<?php
    // Démarrage de la session pour gérer les variables de session
    require_once __DIR__ . '/../includes/auth.php';
    // Inclusion du fichier de connexion à la base de données
    include_once("../connexion-base/connex.inc.php");   
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <!-- Métadonnées de base -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Feuilles de style -->
    <link rel="stylesheet" type="text/css" href="../css/style-of-my-web-site-nav.css">
    <link rel="stylesheet" type="text/css" href="../css/style-of-my-web-site-admi-windows.css">
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="../images/icons/icon.png">
    <title>SantaLogistics - Gestion Enfants</title>
</head>
<?php
    // Inclusion de l'en-tête administrateur
    include("../includes/administrator-header.php");
?>

<main>
    <div id="gestion-enfants" class="home-container">
        <div class="inner1-home-container">
            <h2>Gestion Enfants</h2>
            <div class="sep2"></div>
            <?php if (isset($_SESSION["user_id"])){ ?>
                <!-- Message de bienvenue avec le nom de l'utilisateur connecté -->
                <p>Bienvenue <b><?php echo htmlspecialchars($_SESSION["user_name"]); ?></b> dans la gestion de Gestion Enfants !</p>

                <!-- Section Liste des Enfants -->
                <div class="liste-enfants">
                    <h3>Liste des Enfants</h3>
                    
                    <fieldset>
                        <?php
                            // Affichage des messages de session
                            if (isset($_SESSION['message'])) {
                                echo $_SESSION['message'];
                                
                                unset($_SESSION['message']);
                            }
                        ?>
                        <?php
                            // CONNEXION À LA BASE DE DONNÉES ORACLE
                            $idconn = connexoci("my-param", "oracle2");
                            if (!$idconn) {
                                $e = oci_error();
                                throw new Exception("Erreur de connexion à la base de données : " . $e['message']);
                            }
                            
                            // TRAITEMENT DE LA MODIFICATION D'UN ENFANT
                            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                                if (isset($_POST['id_enfant']) && isset($_POST['modifier'])) {
                                    // Récupération des données du formulaire
                                    $id_enfant = $_POST['id_enfant'];
                                    $nom = $_POST['nom'];
                                    $prenom = $_POST['prenom'];
                                    $adresse = $_POST['adresse'];
                                
                                    // Préparation de la requête SQL de mise à jour
                                    $sql_update = "UPDATE les_enfants SET nom = :nom, prenom = :prenom, adresse = :adresse WHERE RTRIM(id_enfant) = RTRIM(:id_enfant)";
                                    $stid_update = oci_parse($idconn, $sql_update);
                                
                                    // Liaison des paramètres
                                    oci_bind_by_name($stid_update, ':nom', $nom);
                                    oci_bind_by_name($stid_update, ':prenom', $prenom);
                                    oci_bind_by_name($stid_update, ':adresse', $adresse);
                                    oci_bind_by_name($stid_update, ':id_enfant', $id_enfant);

                                    // Exécution de la requête
                                    if (oci_execute($stid_update)) {
                                        $_SESSION['message'] = "<p class='success'>Modification réussie pour l'enfant portant ID : " . htmlspecialchars($id_enfant) . "</p>";
                                        echo '<script>window.location.href = "' . 'gestion_enfants.php' . '";</script>';
                                        exit();
                                    } else {
                                        $_SESSION['message'] = "<p class='error'>Erreur lors de la modification.</p>";
                                        echo '<script>window.location.href = "' . 'gestion_enfants.php' . '";</script>';
                                        exit();
                                    }
                                
                                    oci_free_statement($stid_update);
                                }
                                // TRAITEMENT DE LA SUPPRESSION D'UN ENFANT
                                elseif (isset($_POST['id_enfant']) && isset($_POST['supprimer'])) {
                                    	$id_enfant = $_POST['id_enfant'];
                                        // Supprimer l'enfant
                                        $sql_delete_enfant = "DELETE FROM les_enfants WHERE RTRIM(id_enfant) = RTRIM(:id_enfant)";
                                        $stid_delete_enfant = oci_parse($idconn, $sql_delete_enfant);
                                        oci_bind_by_name($stid_delete_enfant, ':id_enfant', $id_enfant);
                                        
                                        if (oci_execute($stid_delete_enfant)) {
                                            $_SESSION['message'] = "<p class='success'>Enfant et commandes associées supprimés avec succès.</p>";
                                        } else {
                                            $_SESSION['message'] = "<p class='error'>Erreur lors de la suppression de l'enfant.</p>";
                                        }
                                        oci_free_statement($stid_delete_enfant);                          
                                    echo '<script>window.location.href = "' . 'gestion_enfants.php' . '";</script>';
                                    exit();
                                }
                            }
                            
                            // RÉCUPÉRATION DE LA LISTE DES ENFANTS
                            $sql_select = "SELECT * FROM les_enfants ORDER BY nom, prenom";
                            $stid_select = oci_parse($idconn, $sql_select);
                            oci_execute($stid_select);     
                        ?>

                        <!-- TABLEAU AFFICHANT LA LISTE DES ENFANTS -->
                        <h1>Liste des Enfants</h1>
                        <table class="table-style">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Nom</th>
                                    <th>Prénom</th>
                                    <th>Adresse</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php while ($row = oci_fetch_array($stid_select, OCI_ASSOC+OCI_RETURN_NULLS)){ ?>
                                    <tr>
                                        <td><?= htmlspecialchars($row['ID_ENFANT']) ?></td>
                                        <td><?= htmlspecialchars($row['NOM']) ?></td>
                                        <td><?= htmlspecialchars($row['PRENOM']) ?></td>
                                        <td><?= htmlspecialchars($row['ADRESSE']) ?></td>
                                        <td class="actions-cell">
                                            <!-- Formulaire de modification -->
                                            <form method="post" class="inline-form">
<?php echo csrfField(); ?>
                                                <input type="hidden" name="id_enfant" value="<?= htmlspecialchars($row['ID_ENFANT']) ?>">
                                                <input type="text" name="nom" value="<?= htmlspecialchars($row['NOM']) ?>" required>
                                                <input type="text" name="prenom" value="<?= htmlspecialchars($row['PRENOM']) ?>" required>
                                                <input type="text" name="adresse" value="<?= htmlspecialchars($row['ADRESSE']) ?>" required>
                                                <button type="submit" name="modifier" class="btn-modifier">Modifier</button>
                                            </form>
                                            
                                            <!-- Formulaire de suppression -->
                                            <form method="post" class="inline-form" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer cet enfant et toutes ses commandes associées?');">
<?php echo csrfField(); ?>
                                                <input type="hidden" name="id_enfant" value="<?= htmlspecialchars($row['ID_ENFANT']) ?>">
                                                <button type="submit" name="supprimer" class="btn-supprimer">Supprimer</button>
                                            </form>
                                        </td>
                                    </tr>
                                <?php } ?>
                            </tbody>
                        </table>

                       
            <h2>Ajouter un enfant:</h2>
            <fieldset>
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

				<button type="submit" name="envoyer">Ajouter</button>
		    </form>
            </fieldset>
			<?php
                // Traitement du formulaire soumis
                if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['envoyer'])) {
                    // Récupérer les données du formulaire
                    $id_enfant = $_POST['id_enfant'];
                    $nom_enfant = $_POST['nom_enfant'];
                    $prenom_enfant = $_POST['prenom_enfant'];
                    $adresse = $_POST['adresse'];

                    // Valider et sécuriser les données
                    $id_enfant = htmlspecialchars($id_enfant);
                    $nom_enfant = htmlspecialchars($nom_enfant);
                    $prenom_enfant = htmlspecialchars($prenom_enfant);
                    $adresse = htmlspecialchars($adresse);


                    $id_enfant_like = $id_enfant;
                    // Vérifier si l'ID enfant existe déjà
                    $requete = "SELECT COUNT(*) AS COUNT FROM LES_ENFANTS WHERE RTRIM(ID_ENFANT) = RTRIM(:id_enfant)";
                    $stmt = oci_parse($idconn, $requete);
                    oci_bind_by_name($stmt,":id_enfant",$id_enfant_like);
                    oci_execute($stmt);
                    $result_check=oci_fetch_assoc($stmt);
                    oci_free_statement($stmt); // Libérer la ressource
                    // Vérification du résultat
                    //echo $result_check['COUNT'];
                    if ($result_check['COUNT'] == 0) {
                        // Insérer les informations de l'enfant dans la table LES_ENFANTS
                        $requete_insertion = "INSERT INTO LES_ENFANTS (ID_ENFANT, NOM, PRENOM, ADRESSE) VALUES (:id_enfant, :nom_enfant, :prenom_enfant, :adresse)";
                        $stmt_insertion = oci_parse($idconn, $requete_insertion);

                        oci_bind_by_name($stmt_insertion, ":id_enfant", $id_enfant);
                        oci_bind_by_name($stmt_insertion, ":nom_enfant", $nom_enfant);
                        oci_bind_by_name($stmt_insertion, ":prenom_enfant", $prenom_enfant);
                        oci_bind_by_name($stmt_insertion, ":adresse", $adresse);

                        if (!oci_execute($stmt_insertion)) {
                            $e = oci_error($stmt_insertion);
                            throw new Exception("Une erreur s'est produite lors de l'insertion des information de l'enfant.!!!" . $e['message']);
                        }
                        // Libération des ressources
                        oci_free_statement($stmt_insertion);
                        // Valider la transaction
                        $validation = "commit";
                        $stmtv = oci_parse($idconn, $validation);
                        oci_execute($stmtv);
                        // Libération des ressources
                        oci_free_statement($stmtv);
                    
                        $_SESSION['message']="<div class='success'>Les informations de l'enfant ont été ajoutées avec succès !</div>";
                            // Redirection vers la même page après déconnexion
                            echo '<script>window.location.href = "' . 'gestion_enfants.php' . '";</script>';
                            exit();
                    } else {
                        $_SESSION['message']="<div class='error'>L'ID enfant existe déjà !, Changez l'ID ENFANT </div>";
                            // Redirection vers la même page après déconnexion
                            echo '<script>window.location.href = "' . 'gestion_enfants.php' . '";</script>';
                            exit();
                    }
                        
                }
                ?>
                <?php
                    // Libération des ressources
                    oci_free_statement($stid_select);
                    oci_close($idconn);
                ?>

                    </fieldset>
                </div>

            <?php }else{ ?>
                <!-- MESSAGE SI UTILISATEUR NON CONNECTÉ -->
                <p>Veuillez vous connecter pour accéder à la gestion de Gestion Enfants.</p>               
                <p><a href="compte.php">Se connecter</a></p>
            <?php } ?>
        </div>
    </div>
</main>

<?php
    // Inclusion du pied de page administrateur
    include("../includes/administrator-footer.php");
?>