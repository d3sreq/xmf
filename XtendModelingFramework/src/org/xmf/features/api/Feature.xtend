package org.xmf.features.api

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

interface Feature extends EPackageCaseFragmentProvider, EPackageMemberBodyProvider {
	def MemberDeclaration getSourceMemberDeclaration()
	def String getHumanReadableName()
	def String getDefaultValueConstantName()
	def TypeReference getFeatureType()
	def String getGlobalFeatureIdConst()
	def TypeReference getFeatureItemType()
	def String getFeatureVarName()
	def String getGetterName()
	def String getSetterName()
	def String getBasicGetterName()
	def String getBasicSetterName()
}
