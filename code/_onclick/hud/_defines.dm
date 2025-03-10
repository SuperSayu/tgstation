/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Lower left, persistant menu
#define ui_inventory "WEST:6,SOUTH:5"

//Middle left indicators
#define ui_lingchemdisplay "WEST:6,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"

//Lower center, persistant menu
#define ui_sstore1 "CENTER-5:10,SOUTH:5"
#define ui_id "CENTER-4:12,SOUTH:5"
#define ui_belt "CENTER-3:14,SOUTH:5"
#define ui_back "CENTER-2:14,SOUTH:5"
#define ui_rhand "CENTER:-16,SOUTH:5"
#define ui_lhand "CENTER: 16,SOUTH:5"
#define ui_equip "CENTER:-16,SOUTH+1:5"
#define ui_swaphand1 "CENTER:-16,SOUTH+1:5"
#define ui_swaphand2 "CENTER: 16,SOUTH+1:5"
#define ui_storage1 "CENTER+1:18,SOUTH:5"
#define ui_storage2 "CENTER+2:20,SOUTH:5"

#define ui_borg_sensor "CENTER-3:16, SOUTH:5"	//borgs
#define ui_borg_lamp "CENTER-4:16, SOUTH:5"		//borgies
#define ui_inv1 "CENTER-2:16,SOUTH:5"			//borgs
#define ui_inv2 "CENTER-1  :16,SOUTH:5"			//borgs
#define ui_inv3 "CENTER  :16,SOUTH:5"			//borgs
#define ui_borg_module "CENTER+1:16,SOUTH:5"
#define ui_borg_store "CENTER+2:16,SOUTH:5"		//borgs

#define ui_borg_camera "CENTER+3:21,SOUTH:5"	//borgs
#define ui_borg_album "CENTER+4:21,SOUTH:5"		//borgs

#define ui_monkey_head "CENTER-4:13,SOUTH:5"	//monkey
#define ui_monkey_mask "CENTER-3:14,SOUTH:5"	//monkey
#define ui_monkey_back "CENTER-2:15,SOUTH:5"	//monkey

#define ui_alien_storage_l "CENTER-2:14,SOUTH:5"//alien
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"//alien

#define ui_drone_drop "CENTER+1:18,SOUTH:5"     //maintenance drones
#define ui_drone_pull "CENTER+2:2,SOUTH:5"      //maintenance drones
#define ui_drone_storage "CENTER-2:14,SOUTH:5"  //maintenance drones
#define ui_drone_head "CENTER-3:14,SOUTH:5"     //maintenance drones

//Lower right, persistant menu
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_pull_resist "EAST-2:26,SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5"	//alternative intent switcher for when the interface is hidden (F12)

#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"


//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"


//Middle right (status indicators)
#define ui_healthdoll "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_internal "EAST-1:28,CENTER:17"

//borgs and aliens
#define ui_alien_nightvision "EAST-1:28,CENTER:17"
#define ui_borg_health "EAST-1:28,CENTER-1:15"		//borgs have the health display where humans have the pressure damage indicator.
#define ui_alien_health "EAST-1:28,CENTER-1:15"	//aliens have the health display where humans have the pressure damage indicator.
#define ui_alienplasmadisplay "EAST-1:28,CENTER-2:15"

// AI

#define ui_ai_core "SOUTH:6,WEST"
#define ui_ai_camera_list "SOUTH:6,WEST+1"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2"
#define ui_ai_camera_light "SOUTH:6,WEST+3"
#define ui_ai_crew_monitor "SOUTH:6,WEST+4"
#define ui_ai_crew_manifest "SOUTH:6,WEST+5"
#define ui_ai_alerts "SOUTH:6,WEST+6"
#define ui_ai_announcement "SOUTH:6,WEST+7"
#define ui_ai_shuttle "SOUTH:6,WEST+8"
#define ui_ai_state_laws "SOUTH:6,WEST+9"
#define ui_ai_pda_send "SOUTH:6,WEST+10"
#define ui_ai_pda_log "SOUTH:6,WEST+11"
#define ui_ai_take_picture "SOUTH:6,WEST+12"
#define ui_ai_view_images "SOUTH:6,WEST+13"
#define ui_ai_sensor "SOUTH:6,WEST+14"
#define ui_ai_camera_bug "SOUTH+1:6,WEST"

//Pop-up inventory
#define ui_shoes "WEST+1:8,SOUTH:5"

#define ui_iclothing "WEST:6,SOUTH+1:7"
#define ui_oclothing "WEST+1:8,SOUTH+1:7"
#define ui_gloves "WEST+2:10,SOUTH+1:7"

#define ui_glasses "WEST:6,SOUTH+2:9"
#define ui_mask "WEST+1:8,SOUTH+2:9"
#define ui_ears "WEST+2:10,SOUTH+2:9"

#define ui_head "WEST+1:8,SOUTH+3:11"

//Ghosts

#define ui_ghost_jumptomob "SOUTH:6,CENTER-2:16"
#define ui_ghost_orbit "SOUTH:6,CENTER-1:16"
#define ui_ghost_reenter_corpse "SOUTH:6,CENTER:16"
#define ui_ghost_teleport "SOUTH:6,CENTER+1:16"

//Hand of God, god

#define ui_deityhealth "EAST-1:28,CENTER-2:13"
#define ui_deitypower	"EAST-1:28,CENTER-1:15"
#define ui_deityfollowers "EAST-1:28,CENTER:17"
