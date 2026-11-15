import { gsap } from 'gsap'
import { onBeforeUnmount } from 'vue'

const prefersReducedMotion = typeof window !== 'undefined'
  ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
  : false

export function useGsap() {
  const ctx = gsap.context(() => {})

  onBeforeUnmount(() => {
    ctx.revert()
  })

  function animate(target: gsap.TweenTarget, vars: gsap.TweenVars) {
    if (prefersReducedMotion) return undefined
    return ctx.add(() => gsap.to(target, vars))
  }

  function animateFrom(target: gsap.TweenTarget, vars: gsap.TweenVars) {
    if (prefersReducedMotion) return undefined
    return ctx.add(() => gsap.from(target, vars))
  }

  function timeline(vars?: gsap.TimelineVars) {
    const tl = gsap.timeline(vars)
    ctx.add(() => tl)
    return tl
  }

  return {
    animate,
    animateFrom,
    timeline,
    gsap,
  }
}
