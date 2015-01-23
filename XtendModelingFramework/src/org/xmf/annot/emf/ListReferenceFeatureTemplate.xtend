package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.emf.ecore.util.BasicInternalEList
import java.util.Collection

class ListReferenceFeatureTemplate extends AbstractFeatureTemplate {
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	override protected getBodyOfGetter() '''
		if («featureVarName» == null) {
			«featureVarName» = new «BasicInternalEList»<«featureItemType»>(«featureItemType».class);
		}
		return «featureVarName»;
	'''

	override getCaseBodyForEGet() '''
		return «getterName»();
	'''
	
	override getCaseBodyForESet() '''
		«getterName»().clear();
		«getterName»().addAll((«Collection»<? extends «featureItemType»>)newValue);
		return;
	'''
	override getCaseBodyForEUnset() '''
		«getterName»().clear();
		return;
	'''
	
	override getCaseBodyForEIsSet() '''
		return «featureVarName» != null && !«featureVarName».isEmpty();
	'''
}