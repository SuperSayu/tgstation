/obj/structure/closet/secure_closet/quartermaster
	name = "\proper quartermaster's locker"
	req_access = list(access_qm)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/New()
	..()
	new /obj/item/clothing/suit/cloak/qm(src)
	new /obj/item/clothing/under/rank/cargo(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/weapon/mining_voucher(src)
	new /obj/item/device/megaphone/cargo(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/gloves/ring/plasma{stud=1}(src)
