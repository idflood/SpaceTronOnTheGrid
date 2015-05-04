!function(e){function t(n){if(i[n])return i[n].exports;var r=i[n]={exports:{},id:n,loaded:!1};return e[n].call(r.exports,r,r.exports,t),r.loaded=!0,r.exports}var i={};return t.m=e,t.c=i,t.p="assets/",t(0)}({0:function(e,t,i){var n,r=function(e,t){return function(){return e.apply(t,arguments)}};n=function(e){var t,n,o,a;return n=window.THREE,o=i(3),i(13),a=i(4),window.EditorUI=t=function(){function e(){this.initAdd=r(this.initAdd,this),this.initRemove=r(this.initRemove,this),this.onMenuCreated=r(this.onMenuCreated,this);var e,t,i,a,s,c,l,p;this.tweenTime=window.tweenTime,this.editor=new o(this.tweenTime,{json_replacer:function(e,t){return"container"===e?void 0:"parent"===e?void 0:"children"===e?void 0:"object"===e?void 0:"classObject"===e?void 0:t}}),this.onMenuCreated($(".timeline__menu")),e=$(window.app.containerWebgl),a=new n.Vector3,c=new n.Projector,i=new n.Vector2,l=!1,p=new n.Vector3,s=new n.Mesh(new n.PlaneBufferGeometry(3e3,2e3,8,8),new n.MeshBasicMaterial({color:16711680,opacity:.25,transparent:!0})),s.visible=!1,t=function(e){return function(){var e,t,r;return e=window.activeCamera,r=new n.Vector3(i.x,i.y,.5).unproject(e),t=new n.Raycaster(e.position,r.sub(e.position).normalize())}}(this),e.mousedown(function(e){return function(i){var n,r,o;return i.preventDefault(),o=t(),r=o.intersectObjects(window.app.scene.children),r.length&&(n=r[0].object,n._data)?(e.editor.selectionManager.select(n._data),l=n,p=l.position.clone(),r=o.intersectObject(s),a.copy(r[0].point).sub(s.position)):void 0}}(this)),$(window).mouseup(function(e){return function(e){return l=!1}}(this)),e.mousemove(function(n){return function(r){var o,c,u,d,E,h;return i.x=r.clientX/e.width()*2-1,i.y=2*-(r.clientY/e.height())+1,l&&l._data?(d=n.tweenTime.getProperty("x",l._data),E=n.tweenTime.getProperty("y",l._data),h=t(),o=h.intersectObject(s),c=o[0].point.sub(a),u=p.clone().add(c),n.tweenTime.setValue(d,u.x),n.tweenTime.setValue(E,u.y),l._data._isDirty=!0,n.editor.timeline._isDirty=!0):void 0}}(this))}return e.prototype.onMenuCreated=function(e){return e.append('<a class="menu-item menu-item--remove">Remove</a>'),e.prepend('<span class="menu-item">Add<div class="submenu submenu--add"></div></span>'),this.initAdd(e),this.initRemove(e)},e.prototype.initRemove=function(e){var t,i,n;n=this,i=n.editor.selectionManager,t=window.tweenTime.data,e.find(".menu-item--remove").click(function(e){var r,o,s,c,l,p;for(e.preventDefault(),p=i.selection,c=0,l=p.length;l>c;c++)s=p[c],r=a.select(s).datum(),o=t.indexOf(r),r&&r.type&&r.id&&o>-1&&(t.splice(o,1),r.object&&(r.object.destroy(),delete r.object));i.reset(),n.editor.render(!1,!1,!0)})},e.prototype.initAdd=function(e){var t,i,n,r,o,a;if(window.ElementFactory){t=e.find(".submenu--add"),o=window.ElementFactory.elements,a=this;for(r in o)n=o[r],i=$('<a href="#" data-key="'+r+'">'+r+"</a>"),t.append(i);t.find("a").click(function(e){var t,i,n,o,s,c;e.preventDefault(),r=$(this).data("key"),ElementFactory.elements[r]&&(t=a.tweenTime.data,c=t.length+1,o="item"+c,s=r+" "+c,i=a.tweenTime.timer.time[0]/1e3,n={isDirty:!0,id:o,label:s,type:r,start:i,end:i+2,collapsed:!1,properties:ElementFactory.getTypeProperties(r)},a.tweenTime.data.push(n),a.editor.timeline._isDirty=!0)})}},e}()}.call(t,i,t,e),!(void 0!==n&&(e.exports=n))},3:function(e,t,i){e.exports=TweenTime.Editor},4:function(e,t,i){e.exports=d3},13:function(e,t,i){THREE.RenderableObject=function(){this.id=0,this.object=null,this.z=0},THREE.RenderableFace=function(){this.id=0,this.v1=new THREE.RenderableVertex,this.v2=new THREE.RenderableVertex,this.v3=new THREE.RenderableVertex,this.normalModel=new THREE.Vector3,this.vertexNormalsModel=[new THREE.Vector3,new THREE.Vector3,new THREE.Vector3],this.vertexNormalsLength=0,this.color=new THREE.Color,this.material=null,this.uvs=[new THREE.Vector2,new THREE.Vector2,new THREE.Vector2],this.z=0},THREE.RenderableVertex=function(){this.position=new THREE.Vector3,this.positionWorld=new THREE.Vector3,this.positionScreen=new THREE.Vector4,this.visible=!0},THREE.RenderableVertex.prototype.copy=function(e){this.positionWorld.copy(e.positionWorld),this.positionScreen.copy(e.positionScreen)},THREE.RenderableLine=function(){this.id=0,this.v1=new THREE.RenderableVertex,this.v2=new THREE.RenderableVertex,this.vertexColors=[new THREE.Color,new THREE.Color],this.material=null,this.z=0},THREE.RenderableSprite=function(){this.id=0,this.object=null,this.x=0,this.y=0,this.z=0,this.rotation=0,this.scale=new THREE.Vector2,this.material=null},THREE.Projector=function(){function e(){if(c===w){var e=new THREE.RenderableObject;return y.push(e),w++,c++,e}return y[c++]}function t(){if(p===R){var e=new THREE.RenderableVertex;return x.push(e),R++,p++,e}return x[p++]}function i(){if(d===H){var e=new THREE.RenderableFace;return T.push(e),H++,d++,e}return T[d++]}function n(){if(h===g){var e=new THREE.RenderableLine;return b.push(e),g++,h++,e}return b[h++]}function r(){if(f===j){var e=new THREE.RenderableSprite;return M.push(e),j++,f++,e}return M[f++]}function o(e,t){return e.z!==t.z?t.z-e.z:e.id!==t.id?e.id-t.id:0}function a(e,t){var i=0,n=1,r=e.z+e.w,o=t.z+t.w,a=-e.z+e.w,s=-t.z+t.w;return r>=0&&o>=0&&a>=0&&s>=0?!0:0>r&&0>o||0>a&&0>s?!1:(0>r?i=Math.max(i,r/(r-o)):0>o&&(n=Math.min(n,r/(r-o))),0>a?i=Math.max(i,a/(a-s)):0>s&&(n=Math.min(n,a/(a-s))),i>n?!1:(e.lerp(t,i),t.lerp(e,1-n),!0))}var s,c,l,p,u,d,E,h,m,f,v,y=[],w=0,x=[],R=0,T=[],H=0,b=[],g=0,M=[],j=0,V={objects:[],lights:[],elements:[]},z=new THREE.Vector3,S=new THREE.Vector4,C=new THREE.Box3(new THREE.Vector3(-1,-1,-1),new THREE.Vector3(1,1,1)),k=new THREE.Box3,P=new Array(3),F=(new Array(4),new THREE.Matrix4),L=new THREE.Matrix4,B=new THREE.Matrix4,W=new THREE.Matrix3,_=new THREE.Frustum,D=new THREE.Vector4,N=new THREE.Vector4;this.projectVector=function(e,t){console.warn("THREE.Projector: .projectVector() is now vector.project()."),e.project(t)},this.unprojectVector=function(e,t){console.warn("THREE.Projector: .unprojectVector() is now vector.unproject()."),e.unproject(t)},this.pickingRay=function(e,t){console.error("THREE.Projector: .pickingRay() is now raycaster.setFromCamera().")};var O=function(){var e=[],r=[],o=null,a=null,s=new THREE.Matrix3,c=function(t){o=t,a=o.material,s.getNormalMatrix(o.matrixWorld),e.length=0,r.length=0},p=function(e){var t=e.position,i=e.positionWorld,n=e.positionScreen;i.copy(t).applyMatrix4(v),n.copy(i).applyMatrix4(L);var r=1/n.w;n.x*=r,n.y*=r,n.z*=r,e.visible=n.x>=-1&&n.x<=1&&n.y>=-1&&n.y<=1&&n.z>=-1&&n.z<=1},d=function(e,i,n){l=t(),l.position.set(e,i,n),p(l)},h=function(t,i,n){e.push(t,i,n)},m=function(e,t){r.push(e,t)},f=function(e,t,i){return e.visible===!0||t.visible===!0||i.visible===!0?!0:(P[0]=e.positionScreen,P[1]=t.positionScreen,P[2]=i.positionScreen,C.isIntersectionBox(k.setFromPoints(P)))},y=function(e,t,i){return(i.positionScreen.x-e.positionScreen.x)*(t.positionScreen.y-e.positionScreen.y)-(i.positionScreen.y-e.positionScreen.y)*(t.positionScreen.x-e.positionScreen.x)<0},w=function(e,t){var i=x[e],r=x[t];E=n(),E.id=o.id,E.v1.copy(i),E.v2.copy(r),E.z=(i.positionScreen.z+r.positionScreen.z)/2,E.material=o.material,V.elements.push(E)},R=function(t,n,c){var l=x[t],p=x[n],d=x[c];if(f(l,p,d)!==!1&&(a.side===THREE.DoubleSide||y(l,p,d)===!0)){u=i(),u.id=o.id,u.v1.copy(l),u.v2.copy(p),u.v3.copy(d),u.z=(l.positionScreen.z+p.positionScreen.z+d.positionScreen.z)/3;for(var E=0;3>E;E++){var h=3*arguments[E],m=u.vertexNormalsModel[E];m.set(e[h],e[h+1],e[h+2]),m.applyMatrix3(s).normalize();var v=2*arguments[E],w=u.uvs[E];w.set(r[v],r[v+1])}u.vertexNormalsLength=3,u.material=o.material,V.elements.push(u)}};return{setObject:c,projectVertex:p,checkTriangleVisibility:f,checkBackfaceCulling:y,pushVertex:d,pushNormal:h,pushUv:m,pushLine:w,pushTriangle:R}},A=new O;this.projectScene=function(l,y,w,R){d=0,h=0,f=0,V.elements.length=0,l.autoUpdate===!0&&l.updateMatrixWorld(),void 0===y.parent&&y.updateMatrixWorld(),F.copy(y.matrixWorldInverse.getInverse(y.matrixWorld)),L.multiplyMatrices(y.projectionMatrix,F),_.setFromMatrix(L),c=0,V.objects.length=0,V.lights.length=0,l.traverseVisible(function(t){if(t instanceof THREE.Light)V.lights.push(t);else if(t instanceof THREE.Mesh||t instanceof THREE.Line||t instanceof THREE.Sprite){if(t.material.visible===!1)return;(t.frustumCulled===!1||_.intersectsObject(t)===!0)&&(s=e(),s.id=t.id,s.object=t,z.setFromMatrixPosition(t.matrixWorld),z.applyProjection(L),s.z=z.z,V.objects.push(s))}}),w===!0&&V.objects.sort(o);for(var T=0,H=V.objects.length;H>T;T++){var b=V.objects[T].object,g=b.geometry;if(A.setObject(b),v=b.matrixWorld,p=0,b instanceof THREE.Mesh){if(g instanceof THREE.BufferGeometry){var M=g.attributes,j=g.offsets;if(void 0===M.position)continue;for(var C=M.position.array,k=0,P=C.length;P>k;k+=3)A.pushVertex(C[k],C[k+1],C[k+2]);if(void 0!==M.normal)for(var O=M.normal.array,k=0,P=O.length;P>k;k+=3)A.pushNormal(O[k],O[k+1],O[k+2]);if(void 0!==M.uv)for(var I=M.uv.array,k=0,P=I.length;P>k;k+=2)A.pushUv(I[k],I[k+1]);if(void 0!==M.index){var G=M.index.array;if(j.length>0)for(var T=0;T<j.length;T++)for(var U=j[T],$=U.index,k=U.start,P=U.start+U.count;P>k;k+=3)A.pushTriangle(G[k]+$,G[k+1]+$,G[k+2]+$);else for(var k=0,P=G.length;P>k;k+=3)A.pushTriangle(G[k],G[k+1],G[k+2])}else for(var k=0,P=C.length/3;P>k;k+=3)A.pushTriangle(k,k+1,k+2)}else if(g instanceof THREE.Geometry){var X=g.vertices,Y=g.faces,q=g.faceVertexUvs[0];W.getNormalMatrix(v);for(var J=b.material,K=J instanceof THREE.MeshFaceMaterial,Q=K===!0?b.material:null,Z=0,ee=X.length;ee>Z;Z++){var te=X[Z];if(z.copy(te),J.morphTargets===!0)for(var ie=g.morphTargets,ne=b.morphTargetInfluences,re=0,oe=ie.length;oe>re;re++){var ae=ne[re];if(0!==ae){var se=ie[re],ce=se.vertices[Z];z.x+=(ce.x-te.x)*ae,z.y+=(ce.y-te.y)*ae,z.z+=(ce.z-te.z)*ae}}A.pushVertex(z.x,z.y,z.z)}for(var le=0,pe=Y.length;pe>le;le++){var ue=Y[le],J=K===!0?Q.materials[ue.materialIndex]:b.material;if(void 0!==J){var de=J.side,Ee=x[ue.a],he=x[ue.b],me=x[ue.c];if(A.checkTriangleVisibility(Ee,he,me)!==!1){var fe=A.checkBackfaceCulling(Ee,he,me);if(de!==THREE.DoubleSide){if(de===THREE.FrontSide&&fe===!1)continue;if(de===THREE.BackSide&&fe===!0)continue}u=i(),u.id=b.id,u.v1.copy(Ee),u.v2.copy(he),u.v3.copy(me),u.normalModel.copy(ue.normal),fe!==!1||de!==THREE.BackSide&&de!==THREE.DoubleSide||u.normalModel.negate(),u.normalModel.applyMatrix3(W).normalize();for(var ve=ue.vertexNormals,ye=0,we=Math.min(ve.length,3);we>ye;ye++){var xe=u.vertexNormalsModel[ye];xe.copy(ve[ye]),fe!==!1||de!==THREE.BackSide&&de!==THREE.DoubleSide||xe.negate(),xe.applyMatrix3(W).normalize()}u.vertexNormalsLength=ve.length;var Re=q[le];if(void 0!==Re)for(var Te=0;3>Te;Te++)u.uvs[Te].copy(Re[Te]);u.color=ue.color,u.material=J,u.z=(Ee.positionScreen.z+he.positionScreen.z+me.positionScreen.z)/3,V.elements.push(u)}}}}}else if(b instanceof THREE.Line){if(g instanceof THREE.BufferGeometry){var M=g.attributes;if(void 0!==M.position){for(var C=M.position.array,k=0,P=C.length;P>k;k+=3)A.pushVertex(C[k],C[k+1],C[k+2]);if(void 0!==M.index)for(var G=M.index.array,k=0,P=G.length;P>k;k+=2)A.pushLine(G[k],G[k+1]);else for(var He=b.mode===THREE.LinePieces?2:1,k=0,P=C.length/3-1;P>k;k+=He)A.pushLine(k,k+1)}}else if(g instanceof THREE.Geometry){B.multiplyMatrices(L,v);var X=b.geometry.vertices;if(0===X.length)continue;Ee=t(),Ee.positionScreen.copy(X[0]).applyMatrix4(B);for(var He=b.mode===THREE.LinePieces?2:1,Z=1,ee=X.length;ee>Z;Z++)Ee=t(),Ee.positionScreen.copy(X[Z]).applyMatrix4(B),(Z+1)%He>0||(he=x[p-2],D.copy(Ee.positionScreen),N.copy(he.positionScreen),a(D,N)===!0&&(D.multiplyScalar(1/D.w),N.multiplyScalar(1/N.w),E=n(),E.id=b.id,E.v1.positionScreen.copy(D),E.v2.positionScreen.copy(N),E.z=Math.max(D.z,N.z),E.material=b.material,b.material.vertexColors===THREE.VertexColors&&(E.vertexColors[0].copy(b.geometry.colors[Z]),E.vertexColors[1].copy(b.geometry.colors[Z-1])),V.elements.push(E)))}}else if(b instanceof THREE.Sprite){S.set(v.elements[12],v.elements[13],v.elements[14],1),S.applyMatrix4(L);var be=1/S.w;S.z*=be,S.z>=-1&&S.z<=1&&(m=r(),m.id=b.id,m.x=S.x*be,m.y=S.y*be,m.z=S.z,m.object=b,m.rotation=b.rotation,m.scale.x=b.scale.x*Math.abs(m.x-(S.x+y.projectionMatrix.elements[0])/(S.w+y.projectionMatrix.elements[12])),m.scale.y=b.scale.y*Math.abs(m.y-(S.y+y.projectionMatrix.elements[5])/(S.w+y.projectionMatrix.elements[13])),m.material=b.material,V.elements.push(m))}}return R===!0&&V.elements.sort(o),V}}}});
//# sourceMappingURL=Editor.js.map