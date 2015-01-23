package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.emf.ecore.util.InternalEList

class ListContainmentFeatureTemplate extends ListAttributeFeatureTemplate {
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	override getCaseBodyForEInverseRemove() '''
		return ((«InternalEList»)«getterName»()).basicRemove(otherEnd, msgs);
	'''
}