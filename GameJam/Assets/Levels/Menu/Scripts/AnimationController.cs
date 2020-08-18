using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public GameObject MainMenu;
    public GameObject SettingMenu;
    public GameObject ChoicePlayerMenu;
    private bool key;
    private bool key2;


    public void animationPlay(int mode)
    {
        if (mode == 1) //При нажатии кнопки play анимация поднятия
        {
            MainMenu.GetComponent<Animator>().enabled = true;
            MainMenu.GetComponent<Animator>().Play("mainMenuAnimation", -1);
            if (key2 == true)
            {
                ChoicePlayerMenu.GetComponent<Animator>().Play("ChoicePlayerMenuAnimationBack", -1);
            }
            //ChoicePlayerMenu.gameObject.SetActive(true);
            //SettingMenu.gameObject.SetActive(false);
        }
        if (mode == 2)//При нажатии кнопки setting анимация поднятия
        {
            MainMenu.GetComponent<Animator>().enabled = true;
            ChoicePlayerMenu.GetComponent<Animator>().enabled = true;
            ChoicePlayerMenu.GetComponent<Animator>().Play("ChoicePlayerMenuAnimation", -1);
            MainMenu.GetComponent<Animator>().Play("mainMenuAnimation", -1);
            if (key == true)
            {
                SettingMenu.GetComponent<Animator>().Play("SettingAnimationBack", -1);
            }
            key2 = true;
            //ChoicePlayerMenu.gameObject.SetActive(false);
            //SettingMenu.gameObject.SetActive(true);
            
        }
        if (mode == 3)//При нажатии кнопки назад из выбора перса анимация поднятия
        {
            //ChoicePlayerMenu.gameObject.SetActive(true);
            //SettingMenu.gameObject.SetActive(true);
            SettingMenu.GetComponent<Animator>().enabled = true;
            SettingMenu.GetComponent<Animator>().Play("SettingAnimation", -1);
            MainMenu.GetComponent<Animator>().Play("mainMenuAnimationBack", -1);
            key = true;
        }
        if (mode == 4)//При нажатии кнопки назад из настроек анимация поднятия
        {
            //ChoicePlayerMenu.gameObject.SetActive(true);
            //SettingMenu.gameObject.SetActive(true);
            ChoicePlayerMenu.GetComponent<Animator>().enabled = true;
            ChoicePlayerMenu.GetComponent<Animator>().Play("ChoicePlayerMenuAnimation", -1);
            MainMenu.GetComponent<Animator>().Play("mainMenuAnimationBack", -1);
            key2 = true;

        }

    }

    // Start is called before the first frame update
    void Start()
    {
        MainMenu.GetComponent<Animator>().enabled = true;
        MainMenu.GetComponent<Animator>().Play("StartAnimationMainMenu", -1);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
