package io.kryptonite.api.async

class PromiseResult<T> {
  package var T result = null
  package var Throwable error = null
  
  package var (T) => void onResolve = null
  package var (Throwable) => void onReject = null
  
  def void resolve(T data) {
    if (onResolve !== null)
      onResolve.apply(data) //if handler available evoke
    else
      result = data //store result
  }
  
  def void reject(Throwable ex) {
    if (onReject !== null)
      onReject.apply(ex) //if handler available evoke
    else
      error = ex //store error
  }
}