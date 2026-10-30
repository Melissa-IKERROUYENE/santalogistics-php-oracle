-- À exécuter dans un schéma Oracle dédié et vide.
SET DEFINE OFF;
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;

-- Table des spécialités
CREATE TABLE les_specialites (
    id_specialite CHAR(8) PRIMARY KEY,
    nom_specialite VARCHAR(50) NOT NULL
);

-- Table des matières premières
CREATE TABLE les_matieres_premieres (
    id_matiere_premiere CHAR(8) PRIMARY KEY,
    nom_matiere_premiere VARCHAR(50) NOT NULL
);

-- Table des jouets
CREATE TABLE les_jouets (
    id_jouet CHAR(8) PRIMARY KEY,
    num_jouet INT NOT NULL,
    nom_jouet VARCHAR(50) NOT NULL
);

-- Table des ateliers
CREATE TABLE les_ateliers (
    id_atelier CHAR(8) PRIMARY KEY,
    num_atelier INT NOT NULL,
    activite VARCHAR(50) NOT NULL
);

-- Table des fournisseurs
CREATE TABLE les_fournisseurs (
    id_fournisseur CHAR(8) PRIMARY KEY,
    nom_fournisseur VARCHAR(50) NOT NULL
);

-- Table des enfants
CREATE TABLE les_enfants (
    id_enfant CHAR(8) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    adresse VARCHAR(50) NOT NULL
);

-- Table des sous-traitants
CREATE TABLE les_sous_traitants (
    id_sous_traitant CHAR(8) PRIMARY KEY,
    nom_sous_traitant VARCHAR(50) NOT NULL
);

-- Table des itinéraires de distribution
CREATE TABLE les_itineraires_de_distribution (
    id_itineraire CHAR(8) PRIMARY KEY,
    num_itineraire INT NOT NULL,
    depart VARCHAR(50) NOT NULL,
    arrivee VARCHAR(50) NOT NULL
);

-- Table des entrepôts
CREATE TABLE les_entrepots (
    id_entrepot CHAR(8) PRIMARY KEY,
    nom_region VARCHAR(50) NOT NULL
);

-- Table des intermittents
CREATE TABLE les_intermittents (
    id_intermittent CHAR(8) PRIMARY KEY,
    nom_intermittent VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    numero_tel VARCHAR(15) NOT NULL
);

-- Table des équipes de fabrication
CREATE TABLE les_equipes_fabrication (
    id_equipe_fabrication CHAR(8) PRIMARY KEY,
    id_atelier CHAR(8),
    CONSTRAINT fk_equipe_fabrication_atelier FOREIGN KEY (id_atelier) REFERENCES les_ateliers(id_atelier) ON DELETE CASCADE
);

-- Table des équipes logistiques
CREATE TABLE les_equipes_logistiques (
    id_equipe_logistique CHAR(8) PRIMARY KEY,
    id_entrepot CHAR(8),
    CONSTRAINT fk_equipe_logistique_entrepot FOREIGN KEY (id_entrepot) REFERENCES les_entrepots(id_entrepot) ON DELETE CASCADE
);

-- Table de l'historique de fabrication
CREATE TABLE historique_fabrication (
    id_historique CHAR(8) PRIMARY KEY,
    date_entree DATE,
    date_sortie DATE,
    description_etape VARCHAR(200),
    statut_fabrication VARCHAR(50) NOT NULL CHECK (statut_fabrication IN ('en_attente','en_cours', 'termine', 'annule'))
);

-- Table des livraisons
CREATE TABLE livraison (
    id_livraison CHAR(8) PRIMARY KEY,
    statut_livraison VARCHAR(50) NOT NULL CHECK (statut_livraison IN ('en_cours', 'livre', 'annule')),
    date_livraison DATE NOT NULL,
    id_intermittent CHAR(8),
    id_itineraire CHAR(8) NOT NULL,
    CONSTRAINT fk_livraison_intermittent FOREIGN KEY (id_intermittent) REFERENCES les_intermittents(id_intermittent) ON DELETE CASCADE,
    CONSTRAINT fk_livraison_itineraire FOREIGN KEY (id_itineraire) REFERENCES les_itineraires_de_distribution(id_itineraire) ON DELETE CASCADE
);

-- Table des traîneaux
CREATE TABLE les_traineaux (
    id_traineau CHAR(8) PRIMARY KEY,
    num_traineau INT NOT NULL,
    capacite NUMBER NOT NULL,
    id_entrepot CHAR(8) NOT NULL,
    CONSTRAINT fk_traineau_entrepot FOREIGN KEY (id_entrepot) REFERENCES les_entrepots(id_entrepot) ON DELETE CASCADE
);

-- Table des cadeaux
CREATE TABLE les_cadeaux (
    id_cadeau CHAR(8) PRIMARY KEY,
    num_cadeau INT NOT NULL,
    id_traineau CHAR(8) ,
    id_livraison CHAR(8) ,
    id_jouet CHAR(8) ,
    CONSTRAINT fk_cadeau_traineau FOREIGN KEY (id_traineau) REFERENCES les_traineaux(id_traineau) ON DELETE SET NULL,
    CONSTRAINT fk_cadeau_livraison FOREIGN KEY (id_livraison) REFERENCES livraison(id_livraison) ON DELETE SET NULL,
    CONSTRAINT fk_cadeau_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE SET NULL
);

-- Table des elfes
CREATE TABLE les_elfes (
    id_elfe CHAR(8) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    id_traineau CHAR(8),
    id_equipe_fabrication CHAR(8),
    id_equipe_logistique CHAR(8),
    CONSTRAINT fk_elfe_traineau FOREIGN KEY (id_traineau) REFERENCES les_traineaux(id_traineau) ON DELETE SET NULL,
    CONSTRAINT fk_elfe_equipe_fabrication FOREIGN KEY (id_equipe_fabrication) REFERENCES les_equipes_fabrication(id_equipe_fabrication) ON DELETE SET NULL,
    CONSTRAINT fk_elfe_equipe_logistique FOREIGN KEY (id_equipe_logistique) REFERENCES les_equipes_logistiques(id_equipe_logistique) ON DELETE SET NULL,
    CONSTRAINT chk_elfe_affiliation CHECK (
        (id_traineau IS NOT NULL AND id_equipe_fabrication IS NULL AND id_equipe_logistique IS NULL) OR
        (id_traineau IS NULL AND id_equipe_fabrication IS NOT NULL AND id_equipe_logistique IS NULL) OR
        (id_traineau IS NULL AND id_equipe_fabrication IS NULL AND id_equipe_logistique IS NOT NULL) OR 
        (id_traineau IS NULL AND id_equipe_fabrication IS NULL AND id_equipe_logistique IS NULL
        )
        )
);

-- Table des rennes
CREATE TABLE les_rennes (
    id_renne CHAR(8) PRIMARY KEY,
    nom_renne VARCHAR(50) NOT NULL,
    position_renne INT NOT NULL CHECK (position_renne BETWEEN 1 AND 8),
    id_renne_dirigant CHAR(8),
    id_traineau CHAR(8) NOT NULL,
    CONSTRAINT uq_renne_position UNIQUE (id_traineau, position_renne),
    CONSTRAINT fk_renne_traineau FOREIGN KEY (id_traineau) REFERENCES les_traineaux(id_traineau) ON DELETE CASCADE,
    CONSTRAINT fk_renne_dirigant FOREIGN KEY (id_renne_dirigant) REFERENCES les_rennes(id_renne) ON DELETE SET NULL,
    CONSTRAINT chk_renne_position CHECK (position_renne = 1 OR id_renne_dirigant IS NOT NULL)
);

-- Table des spécialités possédées par les elfes
CREATE TABLE possede_specialite (
    id_elfe CHAR(8) NOT NULL,
    id_specialite CHAR(8) NOT NULL,
    type_specialite VARCHAR(50) NOT NULL,
    CONSTRAINT pk_possede_specialite PRIMARY KEY (id_elfe, id_specialite),
    CONSTRAINT fk_possede_specialite_elfe FOREIGN KEY (id_elfe) REFERENCES les_elfes(id_elfe) ON DELETE CASCADE,
    CONSTRAINT fk_possede_specialite_specialite FOREIGN KEY (id_specialite) REFERENCES les_specialites(id_specialite) ON DELETE CASCADE
);

-- Table des chefs d'équipe
CREATE TABLE chef_d_equipe (
    id_elfe_chef CHAR(8) NOT NULL,
    id_equipe_fabrication CHAR(8) NOT NULL,
    CONSTRAINT pk_chef_d_equipe PRIMARY KEY (id_elfe_chef, id_equipe_fabrication),
    CONSTRAINT fk_chef_d_equipe_elfe FOREIGN KEY (id_elfe_chef) REFERENCES les_elfes(id_elfe) ON DELETE CASCADE,
    CONSTRAINT fk_chef_d_equipe_equipe_fabrication FOREIGN KEY (id_equipe_fabrication) REFERENCES les_equipes_fabrication(id_equipe_fabrication) ON DELETE CASCADE
);

-- Table des substitutions de jouets
CREATE TABLE substituer_par (
    id_jouet CHAR(8) NOT NULL,
    id_jouet_remplacant CHAR(8) NOT NULL,
    CONSTRAINT pk_substituer_par PRIMARY KEY (id_jouet, id_jouet_remplacant),
    CONSTRAINT fk_substituer_par_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE,
    CONSTRAINT fk_substituer_par_jouet_remplacant FOREIGN KEY (id_jouet_remplacant) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE
);

-- Table des nécessités de matières premières
CREATE TABLE necessite (
    id_matiere_premiere CHAR(8) NOT NULL,
    id_jouet CHAR(8) NOT NULL,
    CONSTRAINT pk_necessite PRIMARY KEY (id_matiere_premiere, id_jouet),
    CONSTRAINT fk_necessite_matiere_premiere FOREIGN KEY (id_matiere_premiere) REFERENCES les_matieres_premieres(id_matiere_premiere) ON DELETE CASCADE,
    CONSTRAINT fk_necessite_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE
);

-- Table des commandes de matières premières
CREATE TABLE commande (
    id_matiere_premiere CHAR(8) NOT NULL,
    id_fournisseur CHAR(8) NOT NULL,
    quantite VARCHAR(50) NOT NULL,
    date_commande DATE NOT NULL,
    CONSTRAINT pk_commande PRIMARY KEY (id_matiere_premiere, id_fournisseur, date_commande),
    CONSTRAINT fk_commande_matiere_premiere FOREIGN KEY (id_matiere_premiere) REFERENCES les_matieres_premieres(id_matiere_premiere) ON DELETE CASCADE,
    CONSTRAINT fk_commande_fournisseur FOREIGN KEY (id_fournisseur) REFERENCES les_fournisseurs(id_fournisseur) ON DELETE SET NULL
);

-- Table des confiages de jouets aux sous-traitants
CREATE TABLE confie_au (
    id_jouet CHAR(8) NOT NULL,
    id_sous_traitant CHAR(8) NOT NULL,
    id_historique CHAR(8),
    CONSTRAINT pk_confie_au PRIMARY KEY (id_jouet, id_sous_traitant, id_historique),
    CONSTRAINT fk_confie_au_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE,
    CONSTRAINT fk_confie_au_sous_traitant FOREIGN KEY (id_sous_traitant) REFERENCES les_sous_traitants(id_sous_traitant) ON DELETE CASCADE,
    CONSTRAINT fk_confie_au_historique FOREIGN KEY (id_historique) REFERENCES historique_fabrication(id_historique) ON DELETE SET NULL
);

-- Table des remplacements d'elfes
CREATE TABLE remplace_elfe (
    id_elfe_va_remplacer CHAR(8) NOT NULL,
    id_elfe_va_etre_remplacer CHAR(8) NOT NULL,
    date_absence DATE NOT NULL,
    CONSTRAINT pk_remplace_elfe PRIMARY KEY (id_elfe_va_remplacer, id_elfe_va_etre_remplacer, date_absence),
    CONSTRAINT fk_remplace_elfe_elfe_remplacant FOREIGN KEY (id_elfe_va_remplacer) REFERENCES les_elfes(id_elfe) ON DELETE CASCADE,
    CONSTRAINT fk_remplace_elfe_elfe_remplace FOREIGN KEY (id_elfe_va_etre_remplacer) REFERENCES les_elfes(id_elfe) ON DELETE CASCADE
);

-- Table des commandes de jouets par les enfants
CREATE TABLE commande_jouets (
    id_jouet CHAR(8) NOT NULL,
    id_enfant CHAR(8) NOT NULL,
    date_commande DATE NOT NULL,
    CONSTRAINT pk_commande_jouets PRIMARY KEY (id_jouet, id_enfant, date_commande),
    CONSTRAINT fk_commande_jouets_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE,
    CONSTRAINT fk_commande_jouets_enfant FOREIGN KEY (id_enfant) REFERENCES les_enfants(id_enfant) ON DELETE CASCADE
);

-- Table des passages de jouets par les ateliers
CREATE TABLE passe_par (
    id_jouet CHAR(8) NOT NULL,
    id_atelier CHAR(8) NOT NULL,
    id_historique CHAR(8) NOT NULL,
    CONSTRAINT pk_passe_par PRIMARY KEY (id_jouet, id_atelier, id_historique),
    CONSTRAINT fk_passe_par_jouet FOREIGN KEY (id_jouet) REFERENCES les_jouets(id_jouet) ON DELETE CASCADE,
    CONSTRAINT fk_passe_par_atelier FOREIGN KEY (id_atelier) REFERENCES les_ateliers(id_atelier) ON DELETE CASCADE,
    CONSTRAINT fk_passe_par_historique FOREIGN KEY (id_historique) REFERENCES historique_fabrication(id_historique) ON DELETE CASCADE
);

-- Les traîneaux : 8 rennes par traîneau.
-- Les jouets : un jouet ne peut être envoyé soit à un atelier, soit à un sous-traitant, mais pas les deux en même temps.

-- la table lutin  pour les gent qui ven gearer la bdd avec un login et password et non prenom et email du lutin 
CREATE TABLE lutins (
    id_lutin CHAR(8) PRIMARY KEY,
    Nom VARCHAR(50),
    Prenom VARCHAR(50),
    login VARCHAR(16) NOT NULL UNIQUE,
    password CHAR(64) NOT NULL -- bcrypt (60 caractères) ; ancien SHA-256 accepté à la connexion
);

-- inserssion infos
-- Table des spécialités
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC001', 'Fabrication de jouets');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC002', 'Logistique');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC003', 'Géran');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC004', 'Peinture');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC005', 'Menuiserie');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC006', 'Électriciens');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC007', 'Bricolage');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC008', 'Entretien');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC009', 'Designer');
INSERT INTO les_specialites (id_specialite, nom_specialite) VALUES ('SPEC010', 'Mécanicien');

-- Table des matières premières
INSERT INTO les_matieres_premieres (id_matiere_premiere, nom_matiere_premiere) VALUES ('MAT001', 'Bois');
INSERT INTO les_matieres_premieres (id_matiere_premiere, nom_matiere_premiere) VALUES ('MAT002', 'Plastique');
INSERT INTO les_matieres_premieres (id_matiere_premiere, nom_matiere_premiere) VALUES ('MAT003', 'Tissu');

-- Table des jouets
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU001', 1, 'Poupée');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU002', 2, 'Voiture télécommandée');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU003', 3, 'Puzzle');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU004', 4, 'Lego');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU005', 5, 'Peluche');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU006', 6, 'Poupée Barbie');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU007', 7, 'Train électrique');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU008', 8, 'Jeu de société');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU009', 9, 'Ballon de football');
INSERT INTO les_jouets (id_jouet, num_jouet, nom_jouet) VALUES ('JOU010', 10, 'Peluche ours');

-- Table des ateliers
INSERT INTO les_ateliers (id_atelier, num_atelier, activite) VALUES ('ATEL001', 1, 'Assemblage');
INSERT INTO les_ateliers (id_atelier, num_atelier, activite) VALUES ('ATEL002', 2, 'Peinture');
INSERT INTO les_ateliers (id_atelier, num_atelier, activite) VALUES ('ATEL003', 3, 'Emballage');

-- Table des fournisseurs (uniquement Amazon)
INSERT INTO les_fournisseurs (id_fournisseur, nom_fournisseur) VALUES ('FOUR001', 'Amazon');

-- Table des enfants (associés à une région)
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF001', 'Dupont', 'Jean', '1 Rue de la Joie,ville1,ville 3, Europe');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF002', 'Martin', 'Marie', '2 Avenue des Étoiles,ville2, Amérique');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF003', 'Leroy', 'Luc', '3 Boulevard du Bonheur, Asie');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF004', 'Bernard', 'Alice', '4 Rue du Bonheur, Afrique');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF005', 'Petit', 'Louis', '5 Avenue de la Neige,ville2, Amérique');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF006', 'Dubois', 'Emma', '6 Rue des Étoiles,ville1,ville 3, Europe');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF007', 'Lemoine', 'Lucas', '7 Avenue de la Joie,ville2, Amérique');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF008', 'Moreau', 'Chloé', '8 Boulevard du Bonheur, Asie');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF009', 'Girard', 'Hugo', '9 Rue de la Neige, Afrique');
INSERT INTO les_enfants (id_enfant, nom, prenom, adresse) VALUES ('ENF010', 'Roux', 'Léa', '10 Avenue du Soleil,ville2, Amérique');
-- Table des sous-traitants
INSERT INTO les_sous_traitants (id_sous_traitant, nom_sous_traitant) VALUES ('SOUS001', 'Atelier du Nord');
INSERT INTO les_sous_traitants (id_sous_traitant, nom_sous_traitant) VALUES ('SOUS002', 'Fabrique du Sud');
INSERT INTO les_sous_traitants (id_sous_traitant, nom_sous_traitant) VALUES ('SOUS003', 'Usine de l''Est');

-- Table des régions (12 régions)
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT001', 'Amérique du Nord');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT002', 'Amérique du Sud');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT003', 'Europe de l''Ouest');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT004', 'Europe de l''Est');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT005', 'Asie de l''Est');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT006', 'Asie du Sud');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT007', 'Afrique du Nord');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT008', 'Afrique subsaharienne');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT009', 'Océanie');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT010', 'Moyen-Orient');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT011', 'Asie centrale');
INSERT INTO les_entrepots (id_entrepot, nom_region) VALUES ('ENT012', 'Antarctique');

-- Table des itinéraires de distribution (1 par région)
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN001', 1, 'Alaska', 'Amérique du Nord');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN002', 2, 'Alaska', 'Amérique du Sud');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN003', 3, 'Alaska', 'Europe de l''Ouest');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN004', 4, 'Alaska', 'Europe de l''Est');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN005', 5, 'Alaska', 'Asie de l''Est');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN006', 6, 'Alaska', 'Asie du Sud');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN007', 7, 'Alaska', 'Afrique du Nord');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN008', 8, 'Alaska', 'Afrique subsaharienne');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN009', 9, 'Alaska', 'Océanie');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN010', 10, 'Alaska', 'Moyen-Orient');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN011', 11, 'Alaska', 'Asie centrale');
INSERT INTO les_itineraires_de_distribution (id_itineraire, num_itineraire, depart, arrivee) VALUES ('ITIN012', 12, 'Alaska', 'Antarctique');

-- Table des intermittents
INSERT INTO les_intermittents (id_intermittent, nom_intermittent, prenom, numero_tel) VALUES ('INT001', 'Noël', 'caron', '1234567890');
INSERT INTO les_intermittents (id_intermittent, nom_intermittent, prenom, numero_tel) VALUES ('INT002', 'Rudolph', 'yad', '9876543210');
INSERT INTO les_intermittents (id_intermittent, nom_intermittent, prenom, numero_tel) VALUES ('INT003', 'efel', 'Junior', '5555555555');

-- Table des équipes de fabrication
INSERT INTO les_equipes_fabrication (id_equipe_fabrication, id_atelier) VALUES ('EQFAB001', 'ATEL001');
INSERT INTO les_equipes_fabrication (id_equipe_fabrication, id_atelier) VALUES ('EQFAB002', 'ATEL002');
INSERT INTO les_equipes_fabrication (id_equipe_fabrication, id_atelier) VALUES ('EQFAB003', 'ATEL003');

-- Table des équipes logistiques
INSERT INTO les_equipes_logistiques (id_equipe_logistique, id_entrepot) VALUES ('EQLOG001', 'ENT001');
INSERT INTO les_equipes_logistiques (id_equipe_logistique, id_entrepot) VALUES ('EQLOG002', 'ENT002');
INSERT INTO les_equipes_logistiques (id_equipe_logistique, id_entrepot) VALUES ('EQLOG003', 'ENT003');

-- Table de l'historique de fabrication
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST001', TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-02', 'YYYY-MM-DD'), 'Assemblage', 'termine');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST002', TO_DATE('2023-12-02', 'YYYY-MM-DD'), TO_DATE('2023-12-03', 'YYYY-MM-DD'), 'Peinture', 'en_cours');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST003', TO_DATE('2023-12-03', 'YYYY-MM-DD'), TO_DATE('2023-12-05', 'YYYY-MM-DD'), 'Peinture', 'annule');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST004', TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-02', 'YYYY-MM-DD'), 'Assemblage', 'termine');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST005', TO_DATE('2023-12-05', 'YYYY-MM-DD'), TO_DATE('2023-12-07', 'YYYY-MM-DD'), 'Peinture', 'termine');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST006', TO_DATE('2023-12-07', 'YYYY-MM-DD'), TO_DATE('2023-12-08', 'YYYY-MM-DD'), 'Emballage', 'termine');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST007', TO_DATE('2023-12-02', 'YYYY-MM-DD'), TO_DATE('2023-12-06', 'YYYY-MM-DD'), 'Fabrication et emballage', 'en_cours');
INSERT INTO historique_fabrication (id_historique, date_entree, date_sortie, description_etape, statut_fabrication) VALUES ('HIST008', TO_DATE('2023-12-03', 'YYYY-MM-DD'), TO_DATE('2023-12-07', 'YYYY-MM-DD'), 'Fabrication et emballage', 'termine');
-- Table des traîneaux (1 par entrepôt)
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN001', 1, 1000, 'ENT001');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN002', 2, 1000, 'ENT002');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN003', 3, 1000, 'ENT003');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN004', 4, 1000, 'ENT004');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN005', 5, 1000, 'ENT005');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN006', 6, 1000, 'ENT006');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN007', 7, 1000, 'ENT007');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN008', 8, 1000, 'ENT008');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN009', 9, 1000, 'ENT009');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN010', 10, 1000, 'ENT010');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN011', 11, 1000, 'ENT011');
INSERT INTO les_traineaux (id_traineau, num_traineau, capacite, id_entrepot) VALUES ('TRAIN012', 12, 1000, 'ENT012');

-- Table des rennes (8 rennes par traîneau)
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN001', 'Rudolph', 1, NULL, 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN002', 'Comète', 2, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN003', 'Cupidon', 3, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN004', 'Furie', 4, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN005', 'Danseur', 5, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN006', 'Fringant', 6, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN007', 'Tonnerre', 7, 'REN001', 'TRAIN001');
INSERT INTO les_rennes (id_renne, nom_renne, position_renne, id_renne_dirigant, id_traineau) VALUES ('REN008', 'Éclair', 8, 'REN001', 'TRAIN001');
-- Ajoutez les rennes pour les autres traîneaux...

-- Table des elfes
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF001', 'Elfe1', 'TRAIN001', NULL, NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF002', 'Elfe2', NULL, 'EQFAB001', NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF003', 'Elfe3', NULL, NULL, 'EQLOG001');
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF004', 'Elfe4', 'TRAIN001', NULL, NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF005', 'Elfe5', NULL, 'EQFAB001', NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF006', 'Elfe6', NULL, NULL, 'EQLOG001');
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF007', 'Elfe7', 'TRAIN001', NULL, NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF008', 'Elfe8', NULL, 'EQFAB001', NULL);
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF009', 'Elfe9', NULL, NULL, 'EQLOG001');
INSERT INTO les_elfes (id_elfe, nom, id_traineau, id_equipe_fabrication, id_equipe_logistique) VALUES ('ELF0010', 'Elfe10', NULL, NULL, 'EQLOG001');

-- Table des spécialités possédées par les elfes
INSERT INTO possede_specialite (id_elfe, id_specialite, type_specialite) VALUES ('ELF001', 'SPEC001', 'Fabrication');
INSERT INTO possede_specialite (id_elfe, id_specialite, type_specialite) VALUES ('ELF002', 'SPEC002', 'Logistique');
INSERT INTO possede_specialite (id_elfe, id_specialite, type_specialite) VALUES ('ELF003', 'SPEC003', 'Direction');

-- Table des chefs d'équipe
INSERT INTO chef_d_equipe (id_elfe_chef, id_equipe_fabrication) VALUES ('ELF001', 'EQFAB001');
INSERT INTO chef_d_equipe (id_elfe_chef, id_equipe_fabrication) VALUES ('ELF002', 'EQFAB002');
INSERT INTO chef_d_equipe (id_elfe_chef, id_equipe_fabrication) VALUES ('ELF003', 'EQFAB003');

-- Table des substitutions de jouets
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU001', 'JOU002');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU002', 'JOU003');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU003', 'JOU001');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU004', 'JOU002');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU005', 'JOU003');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU006', 'JOU001');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU007', 'JOU002');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU008', 'JOU003');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU009', 'JOU001');
INSERT INTO substituer_par (id_jouet, id_jouet_remplacant) VALUES ('JOU010', 'JOU002');


-- Table des nécessités de matières premières
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT001', 'JOU001');
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT002', 'JOU002');
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT003', 'JOU003');
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT001', 'JOU006');  
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT002', 'JOU007');  
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT003', 'JOU008');
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT001', 'JOU009'); 
INSERT INTO necessite (id_matiere_premiere, id_jouet) VALUES ('MAT003', 'JOU010');

-- Table des commandes de matières premières (toujours à Amazon)
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT001', 'FOUR001', '100', TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT002', 'FOUR001', '200', TO_DATE('2023-11-02', 'YYYY-MM-DD'));
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT003', 'FOUR001', '300', TO_DATE('2023-11-03', 'YYYY-MM-DD'));
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT001', 'FOUR001', '150', TO_DATE('2023-11-04', 'YYYY-MM-DD'));
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT002', 'FOUR001', '250', TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO commande (id_matiere_premiere, id_fournisseur, quantite, date_commande) VALUES ('MAT003', 'FOUR001', '350', TO_DATE('2023-11-06', 'YYYY-MM-DD'));

-- Table des confiages de jouets aux sous-traitants
INSERT INTO confie_au (id_jouet, id_sous_traitant, id_historique) VALUES ('JOU006', 'SOUS001', 'HIST007');
INSERT INTO confie_au (id_jouet, id_sous_traitant, id_historique) VALUES ('JOU007', 'SOUS002', 'HIST008');
INSERT INTO confie_au (id_jouet, id_sous_traitant, id_historique) VALUES ('JOU008', 'SOUS003', 'HIST008');
INSERT INTO confie_au (id_jouet, id_sous_traitant, id_historique) VALUES ('JOU009', 'SOUS003', 'HIST008');

-- Table des remplacements d'elfes
INSERT INTO remplace_elfe (id_elfe_va_remplacer, id_elfe_va_etre_remplacer, date_absence) VALUES ('ELF001', 'ELF002', TO_DATE('2023-12-10', 'YYYY-MM-DD'));
INSERT INTO remplace_elfe (id_elfe_va_remplacer, id_elfe_va_etre_remplacer, date_absence) VALUES ('ELF002', 'ELF003', TO_DATE('2023-12-11', 'YYYY-MM-DD'));

-- Table des commandes de jouets par les enfants
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU001', 'ENF001', TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU002', 'ENF002', TO_DATE('2023-11-02', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU003', 'ENF003', TO_DATE('2023-11-03', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU001', 'ENF006', TO_DATE('2023-11-04', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU002', 'ENF006', TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU003', 'ENF007', TO_DATE('2023-11-06', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU004', 'ENF007', TO_DATE('2023-11-07', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU005', 'ENF008', TO_DATE('2023-11-08', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU006', 'ENF008', TO_DATE('2023-11-09', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU007', 'ENF009', TO_DATE('2023-11-10', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU008', 'ENF009', TO_DATE('2023-11-11', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU009', 'ENF010', TO_DATE('2023-11-12', 'YYYY-MM-DD'));
INSERT INTO commande_jouets (id_jouet, id_enfant, date_commande) VALUES ('JOU010', 'ENF010', TO_DATE('2023-11-13', 'YYYY-MM-DD'));

-- Table des passages de jouets par les ateliers
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU001', 'ATEL001', 'HIST001');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU001', 'ATEL002', 'HIST002');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU001', 'ATEL002', 'HIST003');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU001', 'ATEL002', 'HIST005');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU001', 'ATEL003', 'HIST006');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU002', 'ATEL001', 'HIST004');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU002', 'ATEL002', 'HIST005');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU002', 'ATEL003', 'HIST006');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU003', 'ATEL001', 'HIST004');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU003', 'ATEL002', 'HIST005');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU003', 'ATEL003', 'HIST006');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU004', 'ATEL001', 'HIST004');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU004', 'ATEL002', 'HIST005');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU004', 'ATEL003', 'HIST006');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU005', 'ATEL001', 'HIST004');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU005', 'ATEL002', 'HIST005');
INSERT INTO passe_par (id_jouet, id_atelier, id_historique) VALUES ('JOU005', 'ATEL003', 'HIST006');

-- Table des livraisons
iNSERT INTO livraison (id_livraison, statut_livraison, date_livraison, id_intermittent, id_itineraire) VALUES ('LIV001', 'en_cours', TO_DATE('2023-12-24', 'YYYY-MM-DD'), 'INT001', 'ITIN001');
INSERT INTO livraison (id_livraison, statut_livraison, date_livraison, id_intermittent, id_itineraire) VALUES ('LIV002', 'en_cours', TO_DATE('2023-12-24', 'YYYY-MM-DD'), 'INT002', 'ITIN002');
INSERT INTO livraison (id_livraison, statut_livraison, date_livraison, id_intermittent, id_itineraire) VALUES ('LIV003', 'en_cours', TO_DATE('2023-12-24', 'YYYY-MM-DD'), 'INT003', 'ITIN003');
INSERT INTO livraison (id_livraison, statut_livraison, date_livraison, id_intermittent, id_itineraire) VALUES ('LIV004', 'en_cours', TO_DATE('2023-12-24', 'YYYY-MM-DD'), 'INT001', 'ITIN004');

-- Insertions dans la table les_cadeaux
-- Cadeaux pour l'Europe (ENF001, ENF006)
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD001', 1, 'TRAIN003', 'LIV001', 'JOU001');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD002', 2, 'TRAIN003', 'LIV001', 'JOU001');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD003', 3, 'TRAIN003', 'LIV001', 'JOU002');
-- Cadeaux pour l'Amérique (ENF002, ENF005, ENF007, ENF010)
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD004', 4, 'TRAIN001', 'LIV002', 'JOU002');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD005', 5, 'TRAIN001', 'LIV002', 'JOU003');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD006', 6, 'TRAIN001', 'LIV002', 'JOU004');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD007', 7, 'TRAIN001', 'LIV002', 'JOU010');
-- Cadeaux pour l'Asie (ENF003, ENF008)
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD008', 8, 'TRAIN005', 'LIV003', 'JOU003');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD009', 9, 'TRAIN005', 'LIV003', 'JOU005');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD010', 10, 'TRAIN005', 'LIV003', 'JOU006');
-- Cadeaux pour l'Afrique (ENF004, ENF009)
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD011', 11, 'TRAIN007', 'LIV004', 'JOU007');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD012', 12, 'TRAIN007', 'LIV004', 'JOU008');
INSERT INTO les_cadeaux (id_cadeau, num_cadeau, id_traineau, id_livraison, id_jouet) VALUES ('CAD013', 13, 'TRAIN007', 'LIV004', 'JOU009');
-- Créer un compte via a/inscription.php avec le code privé configuré.
COMMIT;