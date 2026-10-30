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
?>
<main>

    <!--########################################################################################################################-->
    <!-- acceuil ----------------------------------------------------------------------------------------------------------------->
    <div id="accueil" class="home-container">
        <div class="inner-home-container">
            <div class="sep2"></div>
            <h2>Faites Briller les Yeux de Vos Enfants !</h2>
            <p class="intro-text">Découvrez comment rendre vos enfants incroyablement heureux avec notre sélection de cadeaux magiques. Des jouets ludiques, des surprises enchantées, et des moments inoubliables les attendent !</p>
            
            <!-- Section Cadeaux Enfants -->
            <div class="section">
                <h2>"Notre société Chris Kindle" Vous propose Des Cadeaux Qui Font Rêver</h2>
                <p>Offrez à vos enfants des jouets qui stimulent leur imagination et leur créativité. Notre collection est conçue pour émerveiller et amuser les petits comme les grands.</p>
                <div class="image-container">
                    <img src="images/img/toy1.jpg" alt="Peluche renne" class="festive-image">
                    <img src="images/img/toy2.jpg" alt="Train en bois" class="festive-image">
                    <img src="images/img/toy3.jpg" alt="Puzzle Noël" class="festive-image">
                </div>
            </div>

            <!-- Section Bonheur en Famille -->
            <div class="section">
                <h2>Le Bonheur en Famille</h2>
                <p>Noël, c'est avant tout partager des moments précieux en famille. Avec nos idées cadeaux, créez des souvenirs mémorables pour vos enfants.</p>
                <div class="image-container">
                    <img src="images/img/family1.jpg" alt="Famille ouvrant des cadeaux" class="festive-image">
                    <img src="images/img/family2.jpg" alt="Enfants jouant ensemble" class="festive-image">
                    <img src="images/img/family3.jpg" alt="Père Noël avec des enfants" class="festive-image">
                </div>
            </div>

            <button id="festiveButton">Découvrez la Magie de Noël !</button>
            <div id="magicMessage" class="magic-message">
                🎄 Joyeux Noël ! Découvrez la magie de nos cadeaux. 🎁
            </div>
        </div>
    </div>

</main>

<?php
// Inclusion du pied de page
include("includes/cust-footer.php");
?>
