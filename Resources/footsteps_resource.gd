class_name FootstepsResource
extends Resource


enum Pace { FAST, NORMAL, SLOW }
enum Mod { NORMAL, WET, METAL }


const FAST_FOOTSTEP_01 = preload("uid://bj2u5uymwqsxx")
const FAST_FOOTSTEP_02 = preload("uid://bua6s2wd6n8ke")
const FAST_FOOTSTEP_03 = preload("uid://bfwl4fi50nlp")
const FAST_FOOTSTEP_04 = preload("uid://p7aytdgt2cqn")
const FAST_FOOTSTEP_05 = preload("uid://bj5fe00wqxsph")
const FAST_FOOTSTEP_06 = preload("uid://jd14431lq3x0")
const FAST_FOOTSTEP_07 = preload("uid://dmt2wh43yakgj")
const FAST_FOOTSTEP_08 = preload("uid://bu5toc2hdy4ce")
const FAST_FOOTSTEP_09 = preload("uid://dllae3mada0nt")
var fast_footsteps: Array = [
	FAST_FOOTSTEP_01,
	FAST_FOOTSTEP_02,
	FAST_FOOTSTEP_03,
	FAST_FOOTSTEP_04,
	FAST_FOOTSTEP_05,
	FAST_FOOTSTEP_06,
	FAST_FOOTSTEP_07,
	FAST_FOOTSTEP_08,
	FAST_FOOTSTEP_09
]
const FOOTSTEP_01 = preload("uid://crhxrcny28e6h")
const FOOTSTEP_02 = preload("uid://cha064owsqoh0")
const FOOTSTEP_03 = preload("uid://47sixlvx4lcq")
const FOOTSTEP_04 = preload("uid://bmep3oop7q06b")
const FOOTSTEP_05 = preload("uid://ducjj2sg2y78x")
const FOOTSTEP_06 = preload("uid://fghmdu3wu63o")
const FOOTSTEP_07 = preload("uid://c4lunogx8cjl7")
var footsteps: Array = [
	FOOTSTEP_01,
	FOOTSTEP_02,
	FOOTSTEP_03,
	FOOTSTEP_04,
	FOOTSTEP_05,
	FOOTSTEP_06,
	FOOTSTEP_07
]
const SLOW_FOOTSTEP_01 = preload("uid://dklk0hsrg5bgw")
const SLOW_FOOTSTEP_02 = preload("uid://cbmw6w1uwenoc")
const SLOW_FOOTSTEP_03 = preload("uid://chlusknabfn5d")
const SLOW_FOOTSTEP_04 = preload("uid://c5aquhnm5s71s")
const SLOW_FOOTSTEP_05 = preload("uid://cbp4lus65spto")
const SLOW_FOOTSTEP_06 = preload("uid://cxb11nbq8x6b1")
const SLOW_FOOTSTEP_07 = preload("uid://dk3m7xg44j8kx")
var slow_footsteps: Array = [
	SLOW_FOOTSTEP_01,
	SLOW_FOOTSTEP_02,
	SLOW_FOOTSTEP_03,
	SLOW_FOOTSTEP_04,
	SLOW_FOOTSTEP_05,
	SLOW_FOOTSTEP_06,
	SLOW_FOOTSTEP_07
]
func random_footstep(pace: Pace) -> AudioStreamWAV:
	match pace:
		Pace.FAST:
			return fast_footsteps.pick_random()
		Pace.NORMAL:
			return footsteps.pick_random()
		Pace.SLOW:
			return slow_footsteps.pick_random()
	return null

const WET_FAST_FOOTSTEP_01 = preload("uid://cd37a40vdej8b")
const WET_FAST_FOOTSTEP_02 = preload("uid://cqfhbamjjcdne")
const WET_FAST_FOOTSTEP_03 = preload("uid://d2meyjparppre")
const WET_FAST_FOOTSTEP_04 = preload("uid://bfsw0ds6l08qt")
const WET_FAST_FOOTSTEP_05 = preload("uid://c1ih1gma8bu1y")
var wet_fast_footsteps: Array = [
	WET_FAST_FOOTSTEP_01,
	WET_FAST_FOOTSTEP_02,
	WET_FAST_FOOTSTEP_03,
	WET_FAST_FOOTSTEP_04,
	WET_FAST_FOOTSTEP_05
]
const WET_FOOTSTEP_01 = preload("uid://c05jmqj1q248v")
const WET_FOOTSTEP_02 = preload("uid://bcecl4ev7767t")
const WET_FOOTSTEP_03 = preload("uid://qnbybdheoc58")
const WET_FOOTSTEP_04 = preload("uid://77dj8paw4p60")
const WET_FOOTSTEP_05 = preload("uid://dmxfrm7dnadgo")
const WET_FOOTSTEP_06 = preload("uid://dbm5e040l0uxv")
const WET_FOOTSTEP_07 = preload("uid://bqb2payp1m3x")
var wet_footsteps: Array =[
	WET_FOOTSTEP_01,
	WET_FOOTSTEP_02,
	WET_FOOTSTEP_03,
	WET_FOOTSTEP_04,
	WET_FOOTSTEP_05,
	WET_FOOTSTEP_06,
	WET_FOOTSTEP_07
]
const WET_SLOW_FOOTSTEP_01 = preload("uid://ctlxokn7qh5al")
const WET_SLOW_FOOTSTEP_02 = preload("uid://bayeorqfd5wyj")
const WET_SLOW_FOOTSTEP_03 = preload("uid://ckqmvmx06hjn2")
const WET_SLOW_FOOTSTEP_04 = preload("uid://jngltqdlgeoe")
const WET_SLOW_FOOTSTEP_05 = preload("uid://b3vbpt3nmd05v")
var wet_slow_footsteps: Array = [
	WET_SLOW_FOOTSTEP_01,
	WET_SLOW_FOOTSTEP_02,
	WET_SLOW_FOOTSTEP_03,
	WET_SLOW_FOOTSTEP_04,
	WET_SLOW_FOOTSTEP_05
]
func random_wet_footstep(pace: Pace) -> AudioStreamWAV:
	match pace:
		Pace.FAST:
			return wet_fast_footsteps.pick_random()
		Pace.NORMAL:
			return wet_footsteps.pick_random()
		Pace.SLOW:
			return wet_slow_footsteps.pick_random()
	return null

const METAL_FAST_FOOTSTEP_01 = preload("uid://x744g1ghxcu3")
const METAL_FAST_FOOTSTEP_02 = preload("uid://dtm7dlm5wj48g")
const METAL_FAST_FOOTSTEP_03 = preload("uid://bi6suisvx8mj2")
const METAL_FAST_FOOTSTEP_04 = preload("uid://dcucocy3lvfhe")
const METAL_FAST_FOOTSTEP_05 = preload("uid://dx0xfvy4dvqfu")
const METAL_FAST_FOOTSTEP_06 = preload("uid://43s2q5od5r13")
var metal_fast_footsteps: Array = [
	METAL_FAST_FOOTSTEP_01,
	METAL_FAST_FOOTSTEP_02,
	METAL_FAST_FOOTSTEP_03,
	METAL_FAST_FOOTSTEP_04,
	METAL_FAST_FOOTSTEP_05,
	METAL_FAST_FOOTSTEP_06
]
const METAL_FOOTSTEP_01 = preload("uid://5sexs6t30ckf")
const METAL_FOOTSTEP_02 = preload("uid://cxd4bshykixn8")
const METAL_FOOTSTEP_03 = preload("uid://dd74d875r3pei")
const METAL_FOOTSTEP_04 = preload("uid://d20gqxcgbqyj2")
const METAL_FOOTSTEP_05 = preload("uid://dukoxtvj7ortb")
const METAL_FOOTSTEP_06 = preload("uid://d3l3l7262n6tr")
var metal_footsteps: Array = [
	METAL_FOOTSTEP_01,
	METAL_FOOTSTEP_02,
	METAL_FOOTSTEP_03,
	METAL_FOOTSTEP_04,
	METAL_FOOTSTEP_05,
	METAL_FOOTSTEP_06
]
const METAL_SLOW_FOOTSTEP_01 = preload("uid://d1fldcmxbx6rt")
const METAL_SLOW_FOOTSTEP_02 = preload("uid://bdqsqvbce360e")
const METAL_SLOW_FOOTSTEP_03 = preload("uid://b5jhsv8jgglsc")
const METAL_SLOW_FOOTSTEP_04 = preload("uid://d0j4jv0yrtsw3")
const METAL_SLOW_FOOTSTEP_05 = preload("uid://dav3icpw022fx")
const METAL_SLOW_FOOTSTEP_06 = preload("uid://ceh11abb5k3w7")
var metal_slow_footsteps: Array = [
	METAL_SLOW_FOOTSTEP_01,
	METAL_SLOW_FOOTSTEP_02,
	METAL_SLOW_FOOTSTEP_03,
	METAL_SLOW_FOOTSTEP_04,
	METAL_SLOW_FOOTSTEP_05,
	METAL_SLOW_FOOTSTEP_06
]
func random_metal_footstep(pace: Pace) -> AudioStreamWAV:
	match pace:
		Pace.FAST:
			return metal_fast_footsteps.pick_random()
		Pace.NORMAL:
			return metal_footsteps.pick_random()
		Pace.SLOW:
			return metal_slow_footsteps.pick_random()
	return null
