package io.kryptonite.api.async

class Promise<T> {
  val PromiseResult<T> res
  
  new((PromiseResult<T>)=>void sub) {
    res = new PromiseResult<T>
    sub.apply(res)
  }
    
  def Promise<T> then((T) => void onResolve) {
    if (res.result !== null)
      onResolve.apply(res.result)
    else
      res.onResolve = onResolve
    
    return this
  }
  
  def Promise<T> error((Throwable) => void onReject) {
    if (res.error !== null)
      onReject.apply(res.error)
    else
      res.onReject = onReject
    
    return this
  }
}