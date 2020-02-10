#uselib "ksmcore.dll"
#cfunc CreateLineGraph "CreateLineGraph"
#func DestroyLineGraph "DestroyLineGraph" int
#func InsertPointToLineGraph "InsertPointToLineGraph" int, int, double
#func LineGraphValueAt_ "LineGraphValueAt" int, int, var
#cfunc LineGraphContains "LineGraphContains" int, int
#module
#defcfunc LineGraphValueAt int p, int measure, local ret
	ret=0.0f
	LineGraphValueAt_@ p,measure,ret
	return ret
#global
