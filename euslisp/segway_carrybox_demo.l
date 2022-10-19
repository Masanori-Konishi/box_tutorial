(defun init-demo()
  (load "package://msl_hand_controller/euslisp/jaxon_red-interface.l")
  (jaxon_red-init)
  (setq *robot* *jaxon_red*)
  (load "carry_and_put_box2.l")
  ;;(objects (list *robot*))
  ;(send *robot* :limb :right_hand :angle-vector #F(0 90 0 0 0 0))
  ;(send *ri* :angle-vector (send *robot* :angle-vector) 5000 :right_hand-controller) ;;右手だけが動く
  )

;push-recoveryから拝借
(defun lower-waist-no-reset (&optional (dz 60))
  ;(send *robot* :reset-pose)
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :legs :move-end-pos (float-vector 0 0 dz))
  (send *robot* :move-centroid-on-foot :both '(:rleg :lleg))
  (send *ri* :angle-vector (send *robot* :angle-vector) 2000)
  (send *ri* :wait-interpolation)
  )

(defun lower-waist (&optional (dz 60))
  (send *robot* :reset-pose)
  (lower-waist-no-reset dz)
  )

(defun go-stair(&optional (w 400) (h 100) (dx 0))
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector dx 20 0) (float-vector dx -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
        (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
              (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :name :lleg)
              (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector w 0 h)) :name :rleg)
              ))
  )

(defun resetleg()
  (send *ri* :set-auto-balancer-param :default-zmp-offsets (list (float-vector 0 20 0) (float-vector 0 -20 0) (float-vector 0 0 0) (float-vector 0 0 0)))
  (send *ri* :set-foot-steps
        (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
              (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords) :translate (float-vector 0 200 0)) :name :lleg)
              ))
  )

(defun ride-segwaymodel()
  (go-stair 250 120 0)
  )

(defun mydemo-sim ()
  (send *robot* :reset-manip-pose)
  (send *ri* :angle-vector (send *robot* :angle-vector))
  (lower-waist-no-reset)
  (send *ri* :go-pos 0.3 0 0)
  (ride-segwaymodel)
  )
