/**
  * Class Foo
  * ---------
  * Class spéciale qui permet d'étudier n'importe quel variable
  *
  * Exemple :
  *   Tester si "x" est un DOM élément
  *     Foo.is_dom_element(x) // => true si x est un DOM Element
  */
window.Foo = {}
Object.defineProperties(Foo,{
  is_object:{value:function(foo){
    return 'object' == typeof foo ;
  }},
  is_array:{value:function(foo){
    return this.is_object(foo) && 'function'==typeof foo.push ;
  }},
  is_dom_element:{value:function(foo){
    return this.is_object(foo) && this.is_object(foo.ownerDocument) ;
  }},
  is_jquery_element:{value:function(foo){
    return this.is_object(foo) && 'string' == typeof foo.jquery ;
  }},
  is_jquery_event:{value:function(foo){
    return this.is_object(foo) && ('undefined' != typeof foo.currentTarget) && ('undefined' == typeof foo.isTrusted) ;
  }},
  is_dom_event:{value:function(foo){
    if(!this.is_object(foo)){ return false }
    return this.is_object(foo) && ('undefined' != typeof foo.target) && ('undefined' != typeof foo.isTrusted) ;
  }}
  
})