package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend2.lib.StringConcatenationClient

class SingleAttributeFeatureTemplate extends AbstractFeatureTemplate {
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		super(featureRelatedMember, context)
	}
	
	final static private val StringConcatenationClient ZERO = '''0'''
	override getBodyOfDefaultConst() {
		return switch t : featureType {
			case primitiveInt		: ZERO
			case primitiveByte		: ZERO
			case primitiveDouble	: ZERO
			case primitiveFloat		: ZERO
			case primitiveLong		: ZERO
			case primitiveShort		: ZERO
			case primitiveBoolean	: '''false'''
			default: '''null'''
		}
	}
	
	override getBodyOfCachedValue() '''«defaultValueConst»'''
	
	override getBodyOfGetter() '''
		return «featureVarName»;
	'''
	
	override getBodyOfSetter() '''
		«featureVarName» = newValue;
	'''
	
	override getCaseBodyForEGet() '''
		return «getterName»();
	'''
	
	override getCaseBodyForESet() '''
		«setterName»((«featureType»)newValue);
		return;
	'''
	override getCaseBodyForEUnset() '''
		«setterName»(«defaultValueConst»);
		return;
	'''
	
	override getCaseBodyForEIsSet() '''
		«IF featureType.primitive»
			return «featureVarName» != «defaultValueConst»;
		«ELSE»
			return «defaultValueConst» == null ? «featureVarName» != null : !«defaultValueConst».equals(«featureVarName»);
		«ENDIF»
	'''
}