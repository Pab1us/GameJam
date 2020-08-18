using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class CanvasController : MonoBehaviour
{
    public Canvas mainMenu;
    public Canvas settingMenu;
    public Canvas choicePlayerMenu;


    public void chengeCanvas(int mode)
    {
        mainMenu.GetComponent<Canvas>().enabled = true;
        settingMenu.GetComponent<Canvas>().enabled = false;
        choicePlayerMenu.GetComponent<Canvas>().enabled = false;

        if (mode == 1)
        {
            mainMenu.GetComponent<Canvas>().enabled = true;
            settingMenu.GetComponent<Canvas>().enabled = false;
            choicePlayerMenu.GetComponent<Canvas>().enabled = false;
        }
        else if (mode ==2)
        {
            mainMenu.GetComponent<Canvas>().enabled = false;
            settingMenu.GetComponent<Canvas>().enabled = true;
            choicePlayerMenu.GetComponent<Canvas>().enabled = false;
        }
        else if (mode == 3)
        {
            mainMenu.GetComponent<Canvas>().enabled = false;
            settingMenu.GetComponent<Canvas>().enabled = false;
            choicePlayerMenu.GetComponent<Canvas>().enabled = true;
        }

    }

    public void btnPlay()
    {
        SceneManager.LoadScene(1);
    }
}
