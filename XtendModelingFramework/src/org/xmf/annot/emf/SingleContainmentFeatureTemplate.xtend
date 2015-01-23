package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.common.notify.NotificationChain

class SingleContainmentFeatureTemplate extends AbstractFeatureTemplate {

	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	// TODO: same as SingleAttributeFeatureTemplate
	override getBodyOfGetter() '''
		return «featureVarName»;
	'''
	
	override getBodyOfBasicSetter() '''
		«featureType» oldValue = «featureVarName»;
		«featureVarName» = newValue;
		return msgs;
	'''
	
	override getBodyOfSetter() '''
		if (newValue != «featureVarName») {
			«NotificationChain» msgs = null;
			if («featureVarName» != null)
				msgs = ((«InternalEObject»)«featureVarName»).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - «globalFeatureIdConst», null, msgs);
			if (newValue != null)
				msgs = ((«InternalEObject»)newValue).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - «globalFeatureIdConst», null, msgs);
			msgs = «basicSetterName»(newValue, msgs);
			if (msgs != null) msgs.dispatch();
		}
	'''
	
	override getCaseBodyForEInverseRemove() '''
		return  «basicSetterName»(null, msgs);
	'''

	override getCaseBodyForEGet() '''
		return «getterName»();
	'''
	
	override getCaseBodyForESet() '''
		«setterName»((«featureType»)newValue);
		return;
	'''

	// TODO: same as SingleReferenceFeature
	override getCaseBodyForEUnset() '''
		«setterName»((«featureType»)null);
		return;
	'''
	
	// TODO: same as SingleReferenceFeature
	override getCaseBodyForEIsSet() '''
		return «featureVarName» != null;
	'''
}