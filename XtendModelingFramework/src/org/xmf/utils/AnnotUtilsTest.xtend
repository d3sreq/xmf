package org.xmf.utils

import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.macro.declaration.CompilationUnit
import org.junit.Test

import static org.junit.Assert.*

import static extension org.xmf.utils.AnnotUtils.*

class AnnotUtilsTest {
	
	@Test def void test_toConstantName() {
		assertArrayEquals(
			#["CLASS_NAME", "CLASS_NAME", "CLASS_NAME", "XY"],
			#["ClassName",  "className",  "Class_name", "xy"].map[toConstantName]
		)
	}

	@Test def void test_toHumanReadable() {
		assertArrayEquals(
			#["Class Name", "Class Name", "Class Name", "Xy", "Ab C D"],
			#["ClassName",  "className",  "Class_name", "xy", "Ab.c.d"].map[toHumanReadable]
		)
	}
	
	@Test def void test_toGetterName() {
		assertArrayEquals(
			#["getClassName", "getClassName", "getXy"],
			#["ClassName",    "className",    "xy"].map[toGetterName]
		)
	}

	@Test def void test_toSetterName() {
		assertArrayEquals(
			#["setClassName", "setClassName", "setXy"],
			#["ClassName",    "className",    "xy"].map[toSetterName]
		)
	}
	
	static class MockCompilationUnit implements CompilationUnit {
		@Delegate CompilationUnit delegate
		override getPackageName() '''org.mock.something'''
		override getCompilationUnit() {this}
	}
	
	@Test def void test_getModelFactoryName() {
		val mock = new MockCompilationUnit
		assertEquals("org.mock.something.SomethingFactory", mock.getModelFactoryName)
	}

	@Test def void test_getModelPackageName() {
		val mock = new MockCompilationUnit
		assertEquals("org.mock.something.SomethingPackage", mock.modelPackageName)
	}
}