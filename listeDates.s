# TP3 : Programme permettant la lecture en format texte de date et les ordannants 
#		en liste doublement chainee et les affichant les dates dans un ordre croissant
# Auteur:
# Auteur:
#
# Il est a noter que si la date entree n'est pas valide le programme s arrete et 
# affiche les dates deja entree, donc le programme considere incorrecte le 31 Juin par exemple
# car le mois de Juin s arrete toujours au 30 donc il faut que la date entree soit 
# vraiment un date valide( c est a dire qu elle existe) 
#
# Il est a note que pour arreter le programme de la saisie des dates 
# il faut simplement entrer le caractère \n sans aucune entréee
#
.data
msgSol: .string "Entrez les dates de 1900-01-01 a 2500-12-31:\n"
msgAff:	.string "Le contenu de la liste:\n"
msgErr:	.string "L'entree n'est pas valide\n"
buffer:	.space 12			
.text
main:
	call saisir		# fonction permettant de saisir des dates
	call afficher	# fonction permettant l'affichage des dates
fin:
	li a7,10
	ecall
# Fonction permettant de saisir des dates, elle sauvegarde les dates dans une liste
# doublement chainee et les tries en ordre chronologique.
# IN : rien
# OUT: retourne dans a0 l'adresse de debut de la liste doublement chainee
saisir:
	li s4,0
	addi sp,sp,-8
	sd ra,0(sp)		#sauvegarder adresse de retour vers main
	la a0,msgSol
	li a7,4			#afficher le message de solicitation
	ecall
loop_saisir:
	li a7,8
	la a0,buffer	# buffer pour mettre le string du message
	li a1,12
	ecall
	la a0,buffer
	lbu t1,0(a0)
	li t2,'\n'		# condition de fin de saisie
	beq t1,t2,finSaisir
	# verifier si la date saisie est correct pour creer un noeud
	call validerCreer
	beqz a0,errSaisir
	call iterer		# trouver la position ou mettre le noeud dans la liste
	call inserer	# inserer le noeud dans la liste doublement chainee
	j loop_saisir	
errSaisir:
	la a0,msgErr
	li a7,4			# afficher le message d erreur d entrer
	ecall	
finSaisir:
	mv a0,s4
	ld ra,0(sp)
	addi sp,sp,8
	ret
# Fonction permettant de valider la date et creer une Date
# IN : a0 contient l adresse de la chaine qui represente la date
# OUT: a0 contient l'adresse du nouveau maillon creer si la date est valide
# 		sinon 0 est retourner pour dire null et que la date est invalide et pas mallon creer
validerCreer:
	addi sp,sp,-8
	sd ra,0(sp)		# adresse de retour vers la fonction saisir
	mv s0,a0		# s0 contient l adresse du debut de la chaine representant la date
	# Convertir l'annee
	mv a1,s0
	li a2,4
	call atoi
	mv s1,a0		#s1 contient la l annee en int
	# Convertir le mois
	addi a1,s0,5
	li a2,2
	call atoi
	mv s2, a0		# s2 contient le mois en int 
	# Convertir le jour
	addi a1,s0,8
	li a2,2
	call atoi
	mv s3,a0		# s3 contient le jour en int
	# Verifier l annee 
	li t1, 1900		# annee permise debut
	blt s1, t1, date_invalide
	li t1, 2500		# annee permise fin
	bgt s1, t1, date_invalide
	# Verifier le mois
	li t1, 1		# mois Janvier
	blt s2, t1, date_invalide
	li t2, 12		# mois Decembre
	bgt s2, t2, date_invalide
	# Verifier jour
	li t1, 1		# debut des jours permis
	blt s3, t1, date_invalide
	li t2, 31		# fin des jours permis
	bgt s3, t2, date_invalide
	# verification pousser des jours pour voir si concordante avec le mois et le jour
	li t1,4			# Mois de 30 jours Avril
	beq t1,s2,verif_30
	li t1,6			# Mois de 30 jours Juin
	beq t1,s2,verif_30
	li t1, 9		# Mois de 30 jours Septembre
	beq t1,s2,verif_30
	li t1, 9		# Mois de 30 jours Novembre 
	beq t1,s2,verif_30
	# Si pas jour de 30 voir mois de Fevrier
	li t1,2
	beq s2, t1, verif_fevrier
	j date_valide
verif_30:
	li t1, 30		# voir le le jour ne depasse pas le nombre de total dans un mois de 30 jours
	ble s3, t1, date_valide
	bgt s3, t1, date_invalide
verif_fevrier:
	li t1,400		# if (annee % 400 == 0) annee bisextile
	rem t1, s1,t1
	beqz t1,estBisextile
	li t1,100		# else if (annee % 100 == 0) annee est non bisextile
	rem t1, s1,t1
	beqz t1,nonBisextile
	li t1,4			# else if (annee % 4 == 0) annee est bisextile 
	rem t1, s1,t1
	beqz t1,estBisextile
	j nonBisextile	# else annee est non bisextile
estBisextile:
	li t1,29		# si mois de fevrier et annee bisextille on peut aller jusqu a 29
	ble s3,t1,date_valide
	bgt s3,t1,date_invalide
nonBisextile:
	li t1,28		# si mois de fevrier et annee non bisextille on peut aller jusqu a 28
	ble s3,t1,date_valide
	bgt s3,t1,date_invalide
date_invalide:
	li a0,0
	j end_validerCreer
date_valide:
	li a0,28
	li a7,9
	ecall
	sw s1,0(a0)		# sauvegarder le annee dans le nouveau maillon creer
	sw	s2,4(a0)	# sauvegarder le mois dans le nouveau maillon creer
	sw s3,8(a0)		# sauvegarder le jour dans le nouveau maillon creer
end_validerCreer:
	ld ra,0(sp)
	addi sp,sp,8
	ret
# Fonction qui convertit une chaine de caractere en entier
# IN : a1 adresse de la chaine a convertir 
#	   a2 nombre d element de la chaine a convertir	
# OUT: a0 contient la valeur convertie
atoi:
	li t4,0
	li t1,0			# resultat de la conversion
loop_atoi:
	lbu t2,0(a1)
	beqz t2,end_atoi
	addi t2,t2,-48	# convertir en nombre
	li t3,10
	mul t1,t1,t3
	add t1,t1,t2
	addi t4,t4,1
	beq t4,a2,end_atoi
	addi a1,a1,1
	j loop_atoi
end_atoi:
	mv a0, t1
	ret
	
# IN : a0 l adresse du nouveau maillon
#	   s4 l adresse de debut du maillon
# OUT: a1 retourne l'adresse du maillon devant lequel doit etre placer le nouveau noeud
#		sinon retourne 0 si c est le debut du maillon et -1 si c'est la fin de la chaine
# 		qu il faut le mettre
#
iterer:
	addi sp, sp, -24
	sd ra, 0(sp)	# sauvegarder adresse de retour vers la fonction saisir
	sd s4,8(sp)		# sauvegarder adresse de debut de la chaine
	sd a0,16(sp)	# sauvegarder adresse du nouveau maillon creer
	beqz s4,debut_chaine
iterer_loop:
	mv a1, s4
	call plusPetit
	li t1,1
	beq a0,t1,position_trouver
	# si la position n est pas trouver on passe au noeud suivant
	mv a2,s4		# au cas ou on doit mettre le nouveau noeud a la fin de la chaine
	ld s4, 12(s4)	# adresse vers le noeud suivant
	beqz s4, fin_chaine
	ld a0,16(sp)	# remettre l adresse de la chaine pour une nouvel iteration et comparaison
	j iterer_loop
position_trouver:
	mv a1,s4
	ld s4,8(sp)
	# si le nouveau noeud doit etre le debut de la liste mettre a jour le head de la liste
	beq a1,s4,nouveau_debut
	j end_iterer
nouveau_debut:
	ld s4,16(sp)
	j end_iterer	# la position a ete trouver
debut_chaine:
	li a1,0
	j end_iterer
fin_chaine:
	ld s4,8(sp)
	li a1, -1
end_iterer:
	ld ra, 0(sp)
	ld a0,16(sp)
	addi sp,sp,24
	ret 
# permet de comparer deux dates si la nouvelle date est plus petite que la date ou est
# l iteration on retourne true sinon on retourne false s ils sont egaux on retourne false
# IN : a0 l adresse du nouveau maillon (nouvel date a inserer)
#	   a1 l adresse du maillon dont ont fait l'iteration
# OUT : si a1 est plus 
plusPetit:
	# Charger l'annee des deux maillons
	lw t1, 0(a0)
	lw t2, 0(a1)
	
	# Comparer les années
	blt t1, t2, true
	bgt t1, t2, false
	# Si les années sont égales, comparer les mois
	lw t1, 4(a0)
	lw t2, 4(a1)
	
	blt t1, t2, true
	bgt t1, t2, false
	# Si les mois sont égaux, comparer les jours
	lw t1, 8(a0)
	lw t2, 8(a1)
	
	blt t1, t2, true
	bgt t1, t2, false
	
	# Si les jours sont égaux, retourner faux
false:
	li a0, 0
	j end_plusPetit
true:
	li a0, 1
end_plusPetit:
	ret
# Fonction pour insérer un nouveau maillon dans la liste doublement chainee
# IN : a0 l'adresse du nouveau maillon
#	   a1 l'adresse du maillon devant lequel doit être insere le nouveau maillon
#	   a2 l'adresse du dernier maillon de la chaine s il y a lieu
inserer:
	# s il s agit du premier noeud de la liste mettre le head comme le nouveau noeud
	beqz a1,inserer_debut
	li t1,-1
	# si le noeud est le dernier noeud de la liste le mettre a la fin de la liste
	beq a1,t1,inserer_fin
	sd a1,12(a0)		# Nouveau.Suivant = iter.Noeud
	ld t1,20(a1)		
	sd t1,20(a0)		# Nouveau.Precedent = iter.Noeud.Precedent
	sd a0,20(a1)		# iter.Noeud.Precedent = Nouveau
	beqz t1,fin_inserer	
	sd a0,12(t1)		# iter.Noeud.Precedent.Suivant = Nouveau	
	j fin_inserer
inserer_debut:
	mv s4,a0			# head = Nouveau
	j fin_inserer
inserer_fin:
	sd a2,20(a0)		# Nouveau.Precedent = dernier
	sd a0,12(a2)		# dernier.Suivant = Nouveau
fin_inserer:
	ret
# Fonction Permettant d afficher les dates de la liste doublement chainee
# IN: a0 adresse du debut de la liste
# OUT: RIEN
#
afficher:
	addi sp,sp,-8
	sd ra,0(sp)
	beqz a0,fin_afficher
	mv a1,a0
	la a0,msgAff		# message de debut d affichage
	li a7,4
	ecall
loop_afficher:
	# afficher l annee
	lw a0,0(a1)
	li a7,1
	ecall
	li a0,'-'
	
	li a7,11
	ecall
	# afficher le mois
	lw a0,4(a1)
	li t1,9
	ble a0,t1,mettre_zeroM
	li a7,1
	ecall
	j tiretM
mettre_zeroM:
	call afficherZero
tiretM:
	li a0,'-'
	li a7,11
	ecall
	# afficher le jour
	lw a0,8(a1)
	li t1,9
	ble a0,t1,mettre_zeroJ
	li a7,1
	ecall
	j suivant
mettre_zeroJ:
	call afficherZero
suivant:
	li a0,'\n'
	li a7,11
	ecall
	ld a1,12(a1)
	beqz a1,fin_afficher
	j loop_afficher
fin_afficher:
	ld ra,0(sp)
	addi sp,sp,8
	ret	
# Fonction permettant les mois et jour inferieur a 10 sous la forme de 0d
# IN: a0 la valeur a affichier 
# OUT: RIEN 
afficherZero:
	mv t1,a0
	li a0,0
	li a7,1
	ecall
	mv a0,t1
	li a7,1
	ecall
	ret