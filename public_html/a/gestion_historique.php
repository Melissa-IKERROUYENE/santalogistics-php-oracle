<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../connexion-base/connex.inc.php';
// Le fichier de cette rubrique était remplacé par du Java dans l'archive fournie.
// Consultation rétablie à partir du schéma et des parcours montrés dans la vidéo.
$type = $_GET['type'] ?? 'tous';
$id = $_GET['id'] ?? '';
if (!is_string($type) || !in_array($type, ['tous', 'jouet', 'enfant'], true)
    || !is_string($id) || strlen(trim($id)) > 8) {
    http_response_code(400);
    exit('Critères de recherche invalides.');
}
$id = trim($id);
$idconn = connexoci();
$query = "SELECT h.* FROM (
    SELECT j.id_jouet, j.nom_jouet, 'Atelier : ' || RTRIM(p.id_atelier) AS lieu_fabrication,
           hf.id_historique, hf.description_etape, hf.statut_fabrication,
           hf.date_entree, hf.date_sortie
    FROM passe_par p JOIN les_jouets j ON j.id_jouet = p.id_jouet
    JOIN historique_fabrication hf ON hf.id_historique = p.id_historique
    UNION ALL
    SELECT j.id_jouet, j.nom_jouet, 'Sous-traitant : ' || s.nom_sous_traitant AS lieu_fabrication,
           hf.id_historique, hf.description_etape, hf.statut_fabrication,
           hf.date_entree, hf.date_sortie
    FROM confie_au c JOIN les_jouets j ON j.id_jouet = c.id_jouet
    JOIN les_sous_traitants s ON s.id_sous_traitant = c.id_sous_traitant
    JOIN historique_fabrication hf ON hf.id_historique = c.id_historique
) h";
if ($type === 'jouet') {
    $query .= ' WHERE RTRIM(h.id_jouet) = :id';
} elseif ($type === 'enfant') {
    $query .= ' WHERE EXISTS (SELECT 1 FROM commande_jouets cj WHERE cj.id_jouet = h.id_jouet AND RTRIM(cj.id_enfant) = :id)';
}
$query .= ' ORDER BY h.id_jouet, h.date_entree, h.id_historique';
$stmt = oci_parse($idconn, $query);
if ($type !== 'tous') { oci_bind_by_name($stmt, ':id', $id); }
$success = oci_execute($stmt);
?>
<!DOCTYPE html>
<html lang="fr"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../css/style-of-my-web-site-nav.css">
<link rel="stylesheet" href="../css/style-of-my-web-site-admi-windows.css">
<title>SantaLogistics — Historique de fabrication</title></head>
<?php include __DIR__ . '/../includes/administrator-header.php'; ?>
<main><div class="home-container"><div class="inner1-home-container">
<h2>Historique de fabrication</h2>
<form method="get">
<?php echo csrfField(); ?>
<label for="type">Type de recherche :</label>
<select name="type" id="type">
<?php foreach (['tous' => 'Tous les historiques', 'jouet' => 'Par jouet', 'enfant' => 'Par enfant'] as $value => $label) { ?>
<option value="<?= $value ?>" <?= $type === $value ? 'selected' : '' ?>><?= $label ?></option>
<?php } ?>
</select>
<label for="id">ID jouet ou enfant :</label>
<input name="id" id="id" maxlength="8" value="<?= htmlspecialchars($id, ENT_QUOTES, 'UTF-8') ?>">
<button type="submit">Rechercher</button>
</form>
<?php if ($success) { ?>
<table class="table-style"><thead><tr><th>ID jouet</th><th>Jouet</th><th>Lieu de fabrication</th><th>Étape</th><th>Statut</th><th>Entrée</th><th>Sortie</th></tr></thead><tbody>
<?php $count = 0; while ($row = oci_fetch_assoc($stmt)) { $count++; ?>
<tr><?php foreach (['ID_JOUET', 'NOM_JOUET', 'LIEU_FABRICATION', 'DESCRIPTION_ETAPE', 'STATUT_FABRICATION', 'DATE_ENTREE', 'DATE_SORTIE'] as $column) { ?>
<td><?= htmlspecialchars((string)($row[$column] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
<?php } ?></tr>
<?php } ?></tbody></table>
<?php if ($count === 0) { echo '<p>Aucun historique pour cette recherche.</p>'; }
} else { echo '<p>Impossible de charger les historiques.</p>'; }
oci_free_statement($stmt);
oci_close($idconn);
?>
</div></div></main>
<?php include __DIR__ . '/../includes/administrator-footer.php'; ?>
</html>
