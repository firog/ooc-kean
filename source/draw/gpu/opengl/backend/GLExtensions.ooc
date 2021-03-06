/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import egl/egl

GLExtensions: class {
	eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	eglDestroyImageKHR: static Func(Pointer, Pointer)
	glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	eglCreateSyncKHR: static Func(Pointer, UInt, Int*) -> Pointer
	eglDestroySyncKHR: static Func (Pointer, Pointer) -> Bool
	eglClientWaitSyncKHR: static Func (Pointer, Pointer, Int, ULong) -> Bool
	eglDupNativeFenceFDANDROID: static Func(Pointer, Pointer) -> Int
	_initialized := static false
	nativeFenceSupported := static false
	initialize: static func {
		if (!This _initialized) {
			This eglCreateImageKHR = This _load("eglCreateImageKHR") as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This eglDestroyImageKHR = This _load("eglDestroyImageKHR") as Func(Pointer, Pointer)
			This glEGLImageTargetTexture2DOES = This _load("glEGLImageTargetTexture2DOES") as Func(UInt, Pointer)
			This eglCreateSyncKHR = This _load("eglCreateSyncKHR") as Func(Pointer, UInt, Int*) -> Pointer
			This eglDestroySyncKHR = This _load("eglDestroySyncKHR") as Func (Pointer, Pointer) -> Bool
			This eglClientWaitSyncKHR = This _load("eglClientWaitSyncKHR") as Func (Pointer, Pointer, Int, ULong) -> Bool
			version(android) {
				//For some reason this function can't be loaded with eglGetProcAddress so we load it with dlsym instead
				result := dlsym(RTLD_DEFAULT, "eglDupNativeFenceFDANDROID")
				This nativeFenceSupported = (result != null)
				if (!This nativeFenceSupported)
					Debug print("Failed to load OpenGL extension function: eglDupNativeFenceFDANDROID")
				This eglDupNativeFenceFDANDROID = Closure fromPointer(result) as Func(Pointer, Pointer) -> Int
			}
			This _initialized = true
		}
	}
	_load: static func (name: String) -> Closure {
		result := eglGetProcAddress(name toCString())
		if (result == null)
			Debug print~free("Failed to load OpenGL extension function: " << name)
		Closure fromPointer(result)
	}
}
