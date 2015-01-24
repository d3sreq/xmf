package org.xmf.annot.emf.impl

import org.xmf.annot.emf.impl.AbstractFeature
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext

class DerivedFeature extends AbstractFeature {
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	override cachedValueInitializer() {null}
}