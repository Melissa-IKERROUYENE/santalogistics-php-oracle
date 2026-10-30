<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../connexion-base/connex.inc.php';
$idconn = connexoci();
?>
<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/style-of-my-web-site-nav.css">
<link rel="stylesheet" href="../css/style-of-my-web-site-admi-windows.css">
<title>SantaLogistics — Commandes de matières premières</title></head>
<?php include __DIR__ . '/../includes/administrator-header.php'; ?>
<main><div class="home-container"><div class="inner1-home-container">
<h2>Commandes de matières premières</h2>
<?php
$statement = oci_parse($idconn, "SELECT c.id_matiere_premiere, m.nom_matiere_premiere, c.id_fournisseur, f.nom_fournisseur, c.quantite, TO_CHAR(c.date_commande, 'DD/MM/YYYY') AS date_commande FROM commande c JOIN les_matieres_premieres m ON m.id_matiere_premiere = c.id_matiere_premiere JOIN les_fournisseurs f ON f.id_fournisseur = c.id_fournisseur ORDER BY c.date_commande DESC");
if (oci_execute($statement)) { ?>
<table class="table-style"><thead><tr><th>ID matière</th><th>Matière</th><th>ID fournisseur</th><th>Fournisseur</th><th>Quantité</th><th>Date</th></tr></thead><tbody>
<?php while ($row = oci_fetch_assoc($statement)) { ?><tr><td><?= htmlspecialchars((string)($row['ID_MATIERE_PREMIERE'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['NOM_MATIERE_PREMIERE'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['ID_FOURNISSEUR'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['NOM_FOURNISSEUR'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['QUANTITE'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['DATE_COMMANDE'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td></tr><?php } ?>
</tbody></table>
<?php } else { echo '<p>Impossible de charger les données.</p>'; }
oci_free_statement($statement);
oci_close($idconn);
?>
</div></div></main>
<?php include __DIR__ . '/../includes/administrator-footer.php'; ?>
</html>
