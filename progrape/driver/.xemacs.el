;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  XEmacs �� �桼������ե�����Υ���ץ�
;;            MATSUBAYASHI 'Shaolin' Kohji (shaolin@vinelinux.org)
;;                      modified by Jun Nishii (jun@vinelinux.org)
;;                       Time-stamp: <2002/12/05 02:08:32 irokawa>


;;; �������ե�����λ���
;;; �����ǻ��ꤷ���ե�����˥��ץ�������������񤭹��ޤ�ޤ�

(setq user-init-file "~/.xemacs.el")
(setq custom-file "~/.xemacs.el")


;;; ���������ɤλ���

(set-default-coding-systems 'euc-jp)
(set-buffer-file-coding-system 'euc-jp-unix)

(if (eq (console-type) 'tty)
      (set-terminal-coding-system 'euc-jp))

;;;���̤ο�(�������롧�Ť��ֿ�)��������(����80�塢�ġ�40��)

(setq default-frame-alist (append (list '(cursor-color . "purple")
                                        '(width .  80)
                                        '(height . 40))
                                  default-frame-alist))

;;; ��Ԥ� 80 ���ʾ�ˤʤä����ˤϼ�ư���Ԥ���
(setq fill-column 80)
(setq text-mode-hook 'turn-on-auto-fill)
(setq default-major-mode 'text-mode)

;;; �Կ�ɽ��

(custom-set-variables '(line-number-mode t))

;;; gnuclient �����Ф�ư
(load "gnuserv")
(gnuserv-start)

;;; gz�ե�������Խ��Ǥ���褦��
(auto-compression-mode t)

;; �Ķ��ѿ� EMACS_IME ��Ĵ�٤롣- ���ߤΤȤ���canna �ޤ��� Canna �ʤ顢
;; �֤���ʡפ���Ѥ��롣����ʳ��ξ��� Wnn ����Ѥ��롣

(setq emacs-ime (getenv "EMACS_IME"))
(if (null emacs-ime)
    (setq emacs-ime "wnn"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Egg (Wnn �ե��ȥ����) ������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Wnn6/FreeWnn
(if (or (equal emacs-ime "wnn")
        (equal emacs-ime "Wnn")
        (equal emacs-ime "wnn6")
        (equal emacs-ime "Wnn6"))
  (progn
    (load "egg")
    (global-set-key "\C-\\" 'toggle-input-method)

    (select-input-method "japanese-egg-wnn")
    (set-language-info "Japanese" 'input-method "japanese-egg-wnn")

    (setq egg-default-startup-file "eggrc-wnn") ; 95.6.1 by S.Tomura
    (garbage-collect)

    ;; jserver �Υꥹ�Ȥ򼡤��ͤˤ��ƻ���Ǥ��ޤ�
    ;;(setq jserver-list '("vanilla" "espresso"))
    (setq jserver-list (list (getenv "JSERVER") "localhost"))

    ;; "nn" �ǡ֤�פ�����
    (setq enable-double-n-syntax t)

    ;; "." �ǡ֡��ס�"," �ǡ֡��פ����ϡ� 
    (setq use-kuten-for-period nil)
    (setq use-touten-for-comma nil)

    ;; 1234567890%#%"' ���Ⱦ�ѡפ�����"
    (let ((its:*defrule-verbose* nil))
    (its-define-mode "roma-kana")
    (dolist (symbol '("1" "2" "3" "4" "5" 
    		  "6" "7" "8" "9" "0"
    		  "#" "%" "\"" "'" ))
    	(its-defrule symbol symbol)))

    ;; ���ޤ� :-)
    ;;(set-egg-fence-mode-format "��" "��" 'highlight)
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wnn7Egg (Wnn7 �ե��ȥ����) ������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if (or (equal emacs-ime "wnn7")
        (equal emacs-ime "Wnn7"))
    (progn
      (setq load-path (append '("/usr/share/wnn7/elisp/xemacs21") load-path))
      (global-set-key "\C-\\" 'toggle-input-method)
      ;; (global-set-key "\C-o" 'toggle-input-method)
      (load "wnn7egg-leim")
      (select-input-method "japanese-egg-wnn7")
      (set-language-info "Japanese" 'input-method "japanese-egg-wnn7")

      ;; "nn" �ǡ֤�פ�����
      (setq enable-double-n-syntax t)
      ;; ��������⡼��
      (egg-use-input-predict)
      (setq egg-predict-realtime nil)
      ;; ����饤���������⡼��
      (setq egg-predict-mode "inline")
      ;; ������ɥ���������⡼��
      ;(setq egg-predict-mode "window")

      ;; ����ꥹ��ɽ��
      (define-key wnn7-henkan-mode-map " " 'wnn7-henkan-select-kouho-dai)

      ;; 1234567890%#%"'/\| ���Ⱦ�ѡפ�����
      (let ((its:*defrule-verbose* nil))
        (its-define-mode "roma-kana")
        (dolist (symbol '("1" "2" "3" "4" "5" 
                          "6" "7" "8" "9" "0"
                          "#" "%" "\"" "'" "/" "\\" "|"))
                (its-defrule symbol symbol)))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ����ʤ�����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if (or (equal emacs-ime "canna")
	(equal emacs-ime "Canna")
	)
   (progn
      (load-library "canna")

      ;; color-mate ��Ȥ�ʤ��ǡ������Ѵ��˿����դ���������
      (setq canna-use-color t)

      ;; �ե��󥹥⡼�ɤǤʤ���������饤���Ȥ�
      ;;(setq canna-with-fences nil)
      ;;(setq canna-underline t)

      ;; Canna �����Фλ���
      (if (null (getenv "CANNASERVER"))
	  (setq canna-server "localhost")
	(setq canna-server (getenv "CANNASERVER")))
      (canna)

      (global-set-key "\C-_" 'canna-undo)  ;����ɥ������ꡣ
      (setq canna-save-undo-text-predicate ;����ɥ��Хåե����������
            '(lambda (s) (> (length (car s)) 2)) )
      (setq canna-undo-hook ;����ɥ��ܦ���
            '(lambda () (message "���Ѵ����ޤ�....")                          
               (canna-do-function canna-func-henkan)) )

      ;;����ʤ��Ѵ���� BS & DEL ��Ȥ�
      ;;(define-key canna-mode-map [backspace] [?\C-h])
      ;;(define-key canna-mode-map [delete] [?\C-h])

      ;;����ʤ��Ѵ���� C-h ��Ȥ� (with term/keyswap)
      (define-key canna-mode-map [?\177] [?\C-h])

      (select-input-method 'japanese-canna)
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; XEmacs �Υե����/���顼����
;; (color-mate ��Ȥ�ʤ����˿���Ĥ������ꡥ)
;; XEmacs �ˤ� hilit19 ���ʤ��Τǡ����ϤĤ��ޤ��󤬡�
;; ���� font-lock ��ȤäƴʰפǤ�������Ĥ����ޤ���
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(set-face-foreground 'default "black" nil '(x color))
(set-face-background 'default "#eeeeff" nil '(x color))

(require 'font-lock)
(setq font-lock-verbose nil)
(put 'yatex-mode 'font-lock-defaults 'tex-mode)
(put 'yahtml-mode 'font-lock-defaults 'html-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; XEmacs �ǿ����դ��� (color-mate �������ɤ߹���)
;; Vine Linux 2.1 �ޤǤε켰������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;(load "~/.emacs-color.el")
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WEMI (widget ɽ������ SEMI)
;;   Vine 1.9 ����� tm (Tiny Mime) ������� semi ��Ȥ��ޤ�
;;   (Mew �� tm �� semi �ʤ��Ǥ� MIME ���б����Ƥ��ޤ�)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'mime-setup)
(load "path-util")
(setq rmail-enable-mime t)

;; rail-1.0.2 ��Ȥä� User-Agent: �ե�����ɤΥ����ɥ͡�������ܸ첽����
(setq rail-emulate-genjis t)
(if (module-installed-p 'rail) (load "rail"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; T-Gnus 6.13.3 (����)
;;   NetNews �꡼���� GNUS (SEMI �б���)
;;   M-x gnus �ǵ�ư���ޤ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; News Server ̾��ɥᥤ��̾��Ŭ�ڤ˻��ꤷ�Ƥ�������
;(setq gnus-nntp-server "news.hoge.hoge.or.jp")
;(setq gnus-local-domain "hoge.hoge.or.jp")
;(setq gnus-local-organization "HogeHoGe Org.")
;(setq gnus-use-generic-from t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; w3
;;   XEmacs ���ư���֥饦���Ǥ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

;; w3 �ǥץ��������꤬ɬ�פʾ�硢
;; ~/.w3/profile ���������Խ����Ʋ�����.
;; �񼰤ϰʲ����̤�Ǥ�.
;(setq url-proxy-services '(
;      ("http" . "http://proxy.nowhere.ne.jp:8080/")
;      ("ftp" . "http://proxy.nowhere.ne.jp:8080/")
;      ("gopher" . "http://proxy.nowhere.ne.jp:8080/")
;      ("no_proxy" . "://[^/]*nowhere.ne.jp/\\|://192.168"))
;    url-using-proxy t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mew -  Messaging in the Emacs World
;;   �᡼��꡼���� Mew
;;   M-x mew �ǵ�ư���ޤ�
;;   ����ʳ�������� ~/.mew.el �ǹԤ��ޤ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

;; Toolbar���ɲ�
;(setq toolbar-mail-commands-alist (quote ((mew . mew) )))
;(setq toolbar-mail-reader (quote mew))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wanderlust
;;   IMAP �ˤ��б������᡼��/�˥塼���꡼��
;;   ����ʳ�������� ~/.wl �ǹԤ��ޤ�
;;   ~/.wl �Υ���ץ�� /usr/doc/Wanderlust-2.2.12 �ʲ��ˤ���ޤ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-draft "wl" "Write draft with Wanderlust." t)

;; Toolbar���ɲ�
;(setq toolbar-mail-commands-alist (quote ((wl . wl) )))
;(setq toolbar-mail-reader (quote wl))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; X-Face
;;   Mew �� Wanderlust �ʤɤǡ�X-Face �����Ĥ��Υ�å�������ɽ�����ޤ�
;;;  /usr/doc/x-face-xemacs-1.3.6.20.README.ja
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (and window-system (module-installed-p 'x-face))
   (autoload 'x-face-xmas-mew-display-x-face "x-face" nil t)
   (setq wl-highlight-x-face-function
      'x-face-xmas-mew-display-x-face)
   (setq x-face-add-x-face-version-header t))

;; ��ư���̤�ɽ�����ʤ�
;(setq x-face-inhibit-loadup-splash t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; irchat-pj-2.4.24.07
;;   IRC (����å�) ���饤����Ȥ�����
;;   M-x irchat �ǵ�ư���ޤ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'irchat "irchat" nil t)

;;; IRC server �λ���
;;; (�����줫��Ĥ򥳥��ȥ����Ȥ��ޤ�)
;;(setq irchat-server "irc.tohoku.ac.jp")
;;(setq irchat-server "irc.kyutech.ac.jp")
;;(setq irchat-server "irc.tokyo.wide.ad.jp")
;;(setq irchat-server "irc.kyoto.wide.ad.jp")
;;(setq irchat-server "irc.huie.hokudai.ac.jp")
;;(setq irchat-server "irc.cc.yamaguchi-u.ac.jp")
;;(setq irchat-server "irc.karrn.ad.jp")
;;(setq irchat-server "irc.kyoto.wide.ad.jp")

;;; �桼����̾�ȥ˥å��͡���
;;; (nick ��Ⱦ�ѱѿ������ []{}_\^ ����ʤ���� 9 ʸ����ʸ����Ǥ�)
(setq irchat-name "IRC sample user")
(setq irchat-nickname "PJEtest")

;;; �ǥե���Ȥǻ��ä�������ͥ�Υꥹ��
;;;  �ʤ����˽񤤤������ͥ�ˤ� irchat �ε�ư��Ʊ���˻��äǤ��ޤ���
;;(setq irchat-startup-channel-list '("#linuxjp,#pjetest"))
(setq irchat-startup-channel-list '("#VineUsers"))

;;; ���ץ����
;;;   �ܺ٤� /usr/doc/irchat-pj-xemacs-2.4.24.07/doc �ʲ��Υե�����򻲾�
(setq irchat-reconnect-automagic t)      ; �ڤ줿���˺���³���ߤ�
;;(setq irchat-channel-buffer-mode t)    ; ����ͥ�ʬ��ɽ���⡼��
;;(setq irchat-display-channel-always t)
;;(setq irchat-default-freeze-local nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; YaTeX 1.67
;;   [La]TeX ���ϥ⡼��
;;   M-x yatex �Ȥ��뤫��.tex �ǽ����ե�������ɤ߹���ȵ�ư���ޤ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)

;; YaTeX-mode
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(setq dvi2-command "xdvi"
      tex-command "platex"
      dviprint-command-format "dvips %s | lpr"
      YaTeX-kanji-code 3)

;; YaHtml-mode
(setq auto-mode-alist
      (cons (cons "\\.html$" 'yahtml-mode) auto-mode-alist))
(autoload 'yahtml-mode "yahtml" "Yet Another HTML mode" t)
(setq yahtml-www-browser "mozilla")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; �ۥ�����ޥ����б�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(autoload 'mwheel-install "mwheel" "Enable mouse wheel support.")
;(mwheel-install)
;; ���������̤����� (�Ρ��ޥ� . Shift-��������)
;;(setq mwheel-scroll-amount '(5 . 1))

;;=============================================================================
;;                    scroll on  mouse wheel
;;=============================================================================
;; scroll on wheel of mouses
(define-key global-map 'button4
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-down 5)
      (select-window curwin)
)))
(define-key global-map [(shift button4)]
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-down 1)
      (select-window curwin)
)))
(define-key global-map [(control button4)]
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-down)
      (select-window curwin)
)))
(define-key global-map 'button5
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-up 5)
      (select-window curwin)
)))
(define-key global-map [(shift button5)]
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-up 1)
      (select-window curwin)
)))
(define-key global-map [(control button5)]
  '(lambda (&rest args)
    (interactive)
    (let ((curwin (selected-window)))
      (select-window (car (mouse-pixel-position)))
      (scroll-up)
      (select-window curwin)
)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ����¾������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; �ޥ��������ѥ����ɲ�
;;; ~/lib/emacs �ʲ��˥桼���Ѥ� *.el, *.elc ���֤����Ȥ��Ǥ��ޤ�
;;(setq load-path (append '("~/lib/emacs") load-path))


;;; ���ơ������饤��˻��֤�ɽ������
(display-time)


;;; rpm-mode ���ɤ߹���
;;; rpm-mode.el �� spec �ե�����κ����������Ǥ���
;;;   ~/lib/emacs �� /usr/doc/rpm/rpm-mode.el �򥳥ԡ����ưʲ��������
;;; �ԤäƤ���������

;(setq auto-mode-alist (nconc '(("\\.spec" . rpm-mode)) auto-mode-alist))
;(autoload 'rpm-mode "rpm-mode" "Major mode for editing SPEC file of RPM." t) 
;(setq packager "Vine User <vine@hoge.fuga>");��ʬ��̾��
;      (setq buildrootroot "/tmp");BuildRoot�ξ��
;      (setq projectoname "Project Vine");�ץ�������̾ 


;;; �ǽ��������μ�ư����
;;;   �ե��������Ƭ���� 8 �԰���� Time-stamp: <> �ޤ���
;;;   Time-stamp: " " �Ƚ񤤤Ƥ���С������ֻ��˼�ưŪ�����դ���������ޤ�
(if (not (memq 'time-stamp write-file-hooks))
    (setq write-file-hooks
          (cons 'time-stamp write-file-hooks)))


;;;�Хåե��κǸ��newline�ǿ����Ԥ��ɲä���Τ�ػߤ���
(setq next-line-add-newlines nil)

;;;��������
(setq-default lpr-switches '("-2P"))
(setq-default lpr-command "mpage")

;;; �����Х�������
(global-set-key [backspace] 'delete-backward-char) ; BS
(global-set-key [delete] 'delete-char)             ; DEL
(global-set-key "\C-h" 'delete-backward-char)      ; C-h(=DEL)
(global-set-key "\M-?" 'help-for-help)             ; M-?(=help)
(global-set-key [home] 'beginning-of-buffer)       ; HOME(�Хåե�����Ƭ������)
(global-set-key [end] 'end-of-buffer)              ; END(�Хåե��κǸ������)

;;; ���������1��ñ�̤ˤ���
(setq scroll-step 1)

;;; *.~ �Ȥ��ΥХå����åץե��������ʤ�
;(setq make-backup-files nil)

;;; .#* �Ȥ��ΥХå����åץե��������ʤ�
;(setq auto-save-default nil)

;;; �����Խ������ե�����Υ���������֤�Ф�������
(require 'saveplace)
(setq-default save-place t)

;; scratch �⡼�ɤκǽ�Υ�å������Ͼä�
(setq initial-scratch-message nil)

;;; C-t��M-C-t�ǥХåե��ι�®�ڤ��ؤ�
(defun previous-buffer ()
  "Select previous window."
  (interactive)
  (bury-buffer))
(defun backward-buffer ()
  "Select backward window."
  (interactive)
  (switch-to-buffer
   (car (reverse (buffer-list)))))
(global-set-key "\C-t"    'previous-buffer)
(global-set-key "\M-\C-t" 'backward-buffer)


;; Info �Ǥ� frame-title �˾ܤ��������
(add-hook 'Info-startup-hook
          #'(lambda ()
              (make-local-variable 'frame-title-format)
              (setq frame-title-format
                    (concat "*info*  ("
                            (file-name-nondirectory
                             (if (stringp Info-current-file)
                                 Info-current-file
                               (or buffer-file-name "")))
                            ")  "
                            Info-current-node))))
(add-hook 'Info-select-hook
          #'(lambda ()
              (setq frame-title-format
                    (concat "*info*  ("
                            (file-name-nondirectory
                             (if (stringp Info-current-file)
                                 Info-current-file
                               (or buffer-file-name "")))
                            ")  "
                            Info-current-node))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ���Υե�����˴ְ㤤�����ä��������Ƥ�̵���ˤ��ޤ�
(put 'eval-expression 'disabled nil)
