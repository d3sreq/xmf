package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.emf.ecore.InternalEObject

class SingleReferenceFeatureTemplate extends AbstractFeatureTemplate {

	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	override getBodyOfBasicGetter() '''
		return «featureVarName»;
	'''
	
	override getBodyOfGetter() '''
		if («featureVarName» != null && «featureVarName».eIsProxy()) {
			«InternalEObject» oldValue = («InternalEObject»)«featureVarName»;
			«featureVarName» = («featureType»)eResolveProxy(oldValue);
			if («featureVarName» != oldValue) {
			}
		}
		return «featureVarName»;
	'''

	override protected getBodyOfSetter() '''
		«featureVarName» = newValue;
	'''

	override getCaseBodyForEGet() '''
		if (resolve) return «getterName»();
		return «basicGetterName»();
	'''
	
	override getCaseBodyForESet() '''
		«setterName»((«featureType»)newValue);
		return;
	'''
	override getCaseBodyForEUnset() '''
		«setterName»((«featureType»)null);
		return;
	'''
	
	override getCaseBodyForEIsSet() '''
		return «featureVarName» != null;
	'''
}