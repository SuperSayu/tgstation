// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "It monitors power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	use_power = 2
	idle_power_usage = 20
	active_power_usage = 80
	circuit = /obj/item/weapon/circuitboard/powermonitor
	var/datum/powernet/powernet = null
	var/working = 0
	var/progress = 0

//fix for issue 521, by QualityVan.
//someone should really look into why circuits have a powernet var, it's several kinds of retarded.
/obj/machinery/computer/monitor/New()
	..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()

/obj/machinery/computer/monitor/process() //oh shit, somehow we didnt end up with a powernet... lets look for one.
	if(!powernet)
		var/obj/structure/cable/attached = null
		var/turf/T = loc
		if(isturf(T))
			attached = locate() in T
		if(attached)
			powernet = attached.get_powernet()
	return

/obj/machinery/computer/monitor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/monitor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!(istype(user, /mob/living/silicon) || IsAdminGhost(user)))
			user.unset_machine()
			user << browse(null, "window=powcomp")
			return


	user.set_machine(src)
	var/t = ""

	t += "<A href='?src=\ref[src];update'>Refresh</A> <A href='?src=\ref[src];close'>Close</A><br>"
	if(!working)
		t += "<A href='?src=\ref[src];reset'>Reset all APCs</A><br><br>"
	else
		t += "Reset is [progress]% done..."
	if(!powernet)
		t += "<span class='danger'>No connection.</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<PRE>Total power: [powernet.avail] W<BR>Total load:  [num2text(powernet.viewload,10)] W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)

			t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list("<SPAN class='bad'> Off</SPAN>","<SPAN class='bad'>AOff</SPAN>","<SPAN class='good'>  On</SPAN>", "<SPAN class='good'> AOn</SPAN>")
			var/list/chg = list("<SPAN class='bad'>N</SPAN>","<SPAN class='average'>C</SPAN>","<SPAN class='good'>F</SPAN>")

			var/percent = 0
			var/c = ""

			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_tspace("[format_text(A.area.name)]", 30), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]"

				if (A.cell)
					percent = round(A.cell.percent())

					c = "bad"
					if (percent > 50)
						c = "good"
					else if (percent > 25)
						c = "average"

					t += "<SPAN class='[c]'>[add_lspace(percent, 4)]%</SPAN> [chg[A.charging+1]]<BR>"
				else
					t += "   N/C<BR>"

		t += "</FONT></PRE>"

	//user << browse(t, "window=powcomp;size=420x900")
	//onclose(user, "powcomp")
	var/datum/browser/popup = new(user, "powcomp", name, 500, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/monitor/Topic(href, list/href_list)
	if(..())
		return
	if( "close" in href_list )
		usr << browse(null, "window=powcomp")
		usr.unset_machine()
		return
	if( "update" in href_list )
		src.updateDialog()
		return
	if( ("reset" in href_list) && !working)
		working = 1
		spawn(0)
			var/list/L = list()
			for(var/obj/machinery/power/terminal/term in powernet.nodes)
				if(istype(term.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = term.master
					L += A
			var/total = L.len
			var/i = 0
			while(L.len)
				var/obj/machinery/power/apc/A = pick_n_take(L)
				if(A.stat & (BROKEN|MAINT))
					continue
				if(!A.cell || A.aidisabled)
					continue
				A.charging = 0
				A.chargemode = 1
				A.chargecount = 0
				i++
				if(prob(10))
					progress = round((i/total) * 100)
					updateDialog()
					sleep(100)

			working = 0


/obj/machinery/computer/monitor/power_change()

	if(stat & BROKEN)
		icon_state = "broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER

