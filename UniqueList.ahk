/*
	Name: Unique List
	Description: Simple unique-value list
	
	Author: Blucifer
	Date: July 2017
*/

class uniqueList {
	__New() {
		this.list := Object()
	}
	
	add(val) {
		for k, v in this.list {
			if (v = val) {
				return false
			}
		}
		
		this.list.Push(val)
		return true
	}
	
	remove(val) {
		for k, v in this.list {
			if (v = val) {
				this.list.Delete(k)
				return true
			}
		}
		return false
	}
}