package org.xmf.features.impl

import java.util.Collection
import org.eclipse.emf.ecore.util.BasicInternalEList
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration

class ListReference extends AbstractFeature {
	
	new(MemberDeclaration sourceMember, TransformationContext context) {
		super(sourceMember, context)
	}
	
	override getterMethod() '''
		if («featureVarName» == null) {
			«featureVarName» = new «BasicInternalEList»<«featureItemType»>(«featureItemType».class);
		}
		return «featureVarName»;
	'''
	
	override eSet() '''
		«getterName»().clear();
		«getterName»().addAll((«Collection»<? extends «featureItemType»>)newValue);
		return;
	'''
	override eGet() '''return «getterName»();'''
	override eUnset() '''«getterName»().clear();return;'''
	override eIsSet() '''return «featureVarName» != null && !«featureVarName».isEmpty();'''
}