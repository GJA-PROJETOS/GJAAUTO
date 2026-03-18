PROCESS BEFORE OUTPUT.
  MODULE status_9000.

  CALL SUBSCREEN subte_9000 INCLUDING '/GJAAUTO/CKM0001'
                                       gv_screen_number_9000.

PROCESS AFTER INPUT.
  MODULE user_command_9000.
  CALL SUBSCREEN subte_9000.
