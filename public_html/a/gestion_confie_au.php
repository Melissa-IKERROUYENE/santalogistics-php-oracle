<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../connexion-base/connex.inc.php';
$idconn = connexoci();
?>
<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/style-of-my-web-site-nav.css">
<link rel="stylesheet" href="../css/style-of-my-web-site-admi-windows.css">
<title>SantaLogistics — Jouets confiés aux sous-traitants</title></head>
<?php include __DIR__ . '/../includes/administrator-header.php'; ?>
<main><div class="home-container"><div class="inner1-home-container">
<h2>Jouets confiés aux sous-traitants</h2>
<?php
$statement = oci_parse($idconn, "SELECT c.id_jouet, j.nom_jouet, c.id_sous_traitant, s.nom_sous_traitant, c.id_historique, h.statut_fabrication FROM confie_au c JOIN les_jouets j ON j.id_jouet = c.id_jouet JOIN les_sous_traitants s ON s.id_sous_traitant = c.id_sous_traitant LEFT JOIN historique_fabrication h ON h.id_historique = c.id_historique ORDER BY c.id_jouet");
if (oci_execute($statement)) { ?>
<table class="table-style"><thead><tr><th>ID jouet</th><th>Jouet</th><th>ID sous-traitant</th><th>Sous-traitant</th><th>Historique</th><th>Statut</th></tr></thead><tbody>
<?php while ($row = oci_fetch_assoc($statement)) { ?><tr><td><?= htmlspecialchars((string)($row['ID_JOUET'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['NOM_JOUET'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['ID_SOUS_TRAITANT'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['NOM_SOUS_TRAITANT'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['ID_HISTORIQUE'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string)($row['STATUT_FABRICATION'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td></tr><?php } ?>
</tbody></table>
<?php } else { echo '<p>Impossible de charger les données.</p>'; }
oci_free_statement($statement);
oci_close($idconn);
?>
</div></div></main>
<?php include __DIR__ . '/../includes/administrator-footer.php'; ?>
</html>
