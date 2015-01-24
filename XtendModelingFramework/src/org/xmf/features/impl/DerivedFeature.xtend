package org.xmf.features.impl

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration

class DerivedFeature extends AbstractFeature {
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	override cachedValueInitializer() {null}
}