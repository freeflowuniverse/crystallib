module data
import encoding.binary as bin
import time




pub fn (mut generator CodeGenerator) typerecognizer(ffield Field) CRType{	
	mut txt:=ffield.typestr
	mut islist:=false
	if txt.starts_with("[]"){
		islist=true
		txt=txt.all_after("]")
	}
	match txt{
		"u8"{
			return CRType{list:islist,cat:.u8,size:1}
		}
		"u16"{
			return CRType{list:islist,cat:.u16,size:2}
		}
		"u32"{
			return CRType{list:islist,cat:.u32,size:4}
		}
		"u64"{
			return CRType{list:islist,cat:.u64,size:8}
		}
		"int"{
			return CRType{list:islist,cat:.int,size:4}
		}
		"i64"{
			return CRType{list:islist,cat:.i64,size:8}
		}
		"string"{
			return CRType{list:islist,cat:.string}
		}
		"time"{
			return CRType{list:islist,cat:.time,size:8}
		}
		else{
			return CRType{list:islist,cat:.object,modellocation:ffield.modellocation}
		}
	}
}