package org.xmf.annot.emf.impl

import org.eclipse.emf.common.notify.NotificationChain
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration

class SingleContainment extends AbstractFeature {

	new(MemberDeclaration sourceMember, TransformationContext context) {
		super(sourceMember, context)
	}
	
	override getterMethod() '''return «featureVarName»;'''
	
	override setterMethod() '''
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

	override basicSetterMethod() '''
		«featureType» oldValue = «featureVarName»;
		«featureVarName» = newValue;
		return msgs;
	'''
	
	override eInverseRemove() '''return  «basicSetterName»(null, msgs);'''
	override eGet() '''return «getterName»();'''
	override eSet() '''«setterName»((«featureType»)newValue);return;'''
	override eUnset() '''«setterName»((«featureType»)null);return;'''
	override eIsSet() '''return «featureVarName» != null;'''
}