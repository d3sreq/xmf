package org.xmf.annot.emf.impl

import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration

class SingleReference extends AbstractFeature {

	new(MemberDeclaration sourceMember, TransformationContext context) {
		super(sourceMember, context)
	}
	
	override basicGetterMethod() '''return «featureVarName»;'''
	override setterMethod() '''«featureVarName» = newValue;'''
	override getterMethod() '''
		if («featureVarName» != null && «featureVarName».eIsProxy()) {
			«InternalEObject» oldValue = («InternalEObject»)«featureVarName»;
			«featureVarName» = («featureType»)eResolveProxy(oldValue);
			if («featureVarName» != oldValue) {
			}
		}
		return «featureVarName»;
	'''

	override eGet() '''
		if (resolve) return «getterName»();
		return «basicGetterName»();'''
		
	override eSet() '''«setterName»((«featureType»)newValue);return;'''
	override eUnset() '''«setterName»((«featureType»)null);return;'''
	override eIsSet() '''return «featureVarName» != null;'''
}