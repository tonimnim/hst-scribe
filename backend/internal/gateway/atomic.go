package gateway

import "sync/atomic"

// atomicValue is a thin generic wrapper around sync/atomic.Value with a
// fixed type. It exists so sessionConn fields can read like regular
// typed values (lastAudio.Load(), lastAudio.Store(t)) without per-call
// assertions.
type atomicValue[T any] struct {
	v atomic.Value
}

// Load returns the current value, or the zero value of T if none has
// been stored.
func (a *atomicValue[T]) Load() T {
	v, _ := a.v.Load().(T)
	return v
}

// Store sets the current value. The type stored on first call binds T
// for the lifetime of the wrapper.
func (a *atomicValue[T]) Store(v T) {
	a.v.Store(v)
}

// Swap atomically replaces and returns the previous value.
func (a *atomicValue[T]) Swap(v T) T {
	old, _ := a.v.Swap(v).(T)
	return old
}
