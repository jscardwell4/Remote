//
//  Operators.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/12/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

prefix operator ∀⦱ {}

postfix operator ‽ {}

infix operator ⩢ {}
infix operator ∈ 	{  // element of
associativity none
precedence 130
}
infix operator ∉ 	{  // not an element of
associativity none
precedence 130
}
infix operator ∋ 	{  // has as member
associativity none
precedence 130
}
infix operator ∌ 	{  // does not have as member
associativity none
precedence 130
}
infix operator ∖ 	{  // minus
associativity none
precedence 130
}
infix operator ∪ 	{  // union
associativity none
precedence 130
}
infix operator ∩ 	{  // intersection
associativity none
precedence 130
}
infix operator ∖= 	{  // minus equals
associativity right
precedence 90
}
infix operator ∪= 	{  // union equals
associativity right
precedence 90
assignment
}
infix operator ∩= 	{  // intersection equals
associativity right
precedence 90
assignment
}
infix operator ⊂ 	{  // subset of
associativity none
precedence 130
}
infix operator ⊄ 	{  // not a subset of
associativity none
precedence 130
}
infix operator ⊆ {
associativity none
precedence 130
}
infix operator ⊇ {
associativity none
precedence 130
}
infix operator ⊈ {
associativity none
precedence 130
}
infix operator ⊉ {
associativity none
precedence 130
}
infix operator ⊃ 	{  // superset of
associativity none
precedence 130
}
infix operator ⊅ 	{  // not a superset of
associativity none
precedence 130
}
postfix operator ⭆ {}

infix operator ⥢ {
associativity right
precedence 90
}
prefix operator ⇇ {}

infix operator ∅|| {
associativity right
precedence 130
}
infix operator ➤ {
associativity none
precedence 130
}
infix operator ➤| {
associativity none
precedence 130
}
prefix operator ‽∪ {}
prefix operator ‽ {}
prefix operator !? {}
prefix operator ∑ {}
prefix operator ∪ {}
prefix operator ⨳ {}
prefix operator % {}
prefix operator ⁂ {}
prefix operator ※ {}
prefix operator ✧ {}
prefix operator ★ {}
prefix operator ∴ {}
prefix operator ∷ {}
prefix operator ≡ {}
prefix operator ⊷ {}
prefix operator ≀ {}
prefix operator ⩨ {}
prefix operator ⦙ {}
