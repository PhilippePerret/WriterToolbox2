Dernière note : 1

### 0001 {#note_1}

Il serait plus logique que les opération soient traitées seulement dans les parties des tâches. Malheureusement, si on fait ça, si on ne les traite qu'en chargeant leur partiel, les onglets seront traités avant et, donc, ne correspondront pas à la réalité. Par exemple, s'il reste deux tâches à finir et que l'opération doit en retirer une, les onglets afficheront "2 tâches" alors qu'il n'y en aura plus qu'une après l'opération.

Moralité : il est important de traiter les opérations sur les tâches (ou même sur les infos, les préférences, etc.) AVANT la construction des onglets.
