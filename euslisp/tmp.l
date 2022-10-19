(load "package://push-recovery/push-recovery-foot-guided.l")
(robots-init "jaxon_red")
(start-footguided-modification)

(send *ri* :go-pos -0.5 0 0)
(format t "hogehoge~%")
(send *ri* :go-pos 0.2 0 0)
