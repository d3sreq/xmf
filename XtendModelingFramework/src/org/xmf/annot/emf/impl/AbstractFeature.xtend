package org.xmf.annot.emf.impl

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.xmf.annot.emf.api.Feature

import static extension org.xmf.utils.AnnotUtils.*

abstract class AbstractFeature implements Feature {

	protected extension TransformationContext context
	private MemberDeclaration sourceMember
	
	new(MemberDeclaration sourceMember, TransformationContext context) {
		this.context = context
		this.sourceMember = sourceMember
	}

	final override getFeatureType() {
		switch m : sourceMember {
			FieldDeclaration : m.type
			MethodDeclaration : m.returnType
		}
	}
	
	// from Feature
	final override getSourceMemberDeclaration() {sourceMember}
	final override getFeatureVarName() {sourceMember.simpleName}
	final override getHumanReadableName() {sourceMember.simpleName.toHumanReadable}
	final override getGlobalFeatureIdConst() {sourceMember.toGlobalFeatureIdConst}
	final override getFeatureItemType() {getFeatureType.actualTypeArguments.head}
	final override getGetterName() {sourceMember.toGetterName}
	final override getSetterName() {sourceMember.toSetterName}
	final override getBasicGetterName() '''basic«getterName.toFirstUpper»'''
	final override getBasicSetterName() '''basic«setterName.toFirstUpper»'''
	final override getDefaultValueConstantName() {sourceMember.toEDEFAULT}
	
	// from EPackageCaseFragmentProvider
	override eInverseRemove() {null}
	override eGet() {null}
	override eSet() {null}
	override eUnset() {null}
	override eIsSet() {null}

	// from EPackageMemberBodyProvider
	override defaultValueInitializer() {null}
	override cachedValueInitializer() '''null'''
	override getterMethod() {null}
	override setterMethod() {null}
	override basicGetterMethod() {null}
	override basicSetterMethod() {null}


	
}