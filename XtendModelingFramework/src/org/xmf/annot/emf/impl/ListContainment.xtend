package org.xmf.annot.emf.impl

import org.eclipse.emf.ecore.util.InternalEList
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration

class ListContainment extends ListAttribute {
	
	new(MemberDeclaration sourceMember, TransformationContext context) {
		super(sourceMember, context)
	}
	
	override eInverseRemove() '''
		return ((«InternalEList»)«getterName»()).basicRemove(otherEnd, msgs);
	'''
}