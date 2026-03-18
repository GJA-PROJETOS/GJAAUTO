PROCESS BEFORE OUTPUT.
  MODULE status_9003.

  CALL SUBSCREEN subte_9003 INCLUDING '/GJAAUTO/CKM0001'
                                      gv_screen_number_9003.
*
PROCESS AFTER INPUT. "Transferido para a tela principal 9000
  MODULE user_command_9003.
  CALL SUBSCREEN subte_9003.
