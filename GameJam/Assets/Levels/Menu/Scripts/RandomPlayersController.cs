using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RandomPlayersController : MonoBehaviour
{
    public Sprite litleMuk;
    public Sprite indianaJons;
    public Sprite laraCroft;
    public Sprite montyHoll;
    public Sprite nostradama;
    public GameObject animationController;
    public GameObject panelReady;
    public Image readyHeroes;
    public Text textInputNameHeroes;
    public Text info;

    public void btnRandomPers()
    {
        System.Random rand = new System.Random();
        int mode = rand.Next(1, 7);
        if (mode == 1)
        {
            textInputNameHeroes.text = "Маленький Мук";
            Globals.mainCharacter = "litleMuk";
            animationController.GetComponent<Animator>().enabled = true;
            animationController.GetComponent<Animator>().Play("player1Anim", -1);
            readyHeroes.GetComponent<Image>().sprite = litleMuk;
            info.GetComponent<Text>().text = "визуально - хил и слаб, уродец-торговец найденные сокровища умножатся x1.53 слота под артефакты";
            //panelReady.gameObject.SetActive(true);
        }
        if (mode == 2)
        {
            textInputNameHeroes.text = "Индиана Джонс";
            Globals.mainCharacter = "indianaJons";
            animationController.GetComponent<Animator>().enabled = true;
            animationController.GetComponent<Animator>().Play("player2Anim", -1);
            readyHeroes.GetComponent<Image>().sprite = indianaJons;
            info.GetComponent<Text>().text = "визуально - приключенец при попадании в ловушку теряет только половину сокровищ 2 слота под артефакты";
            //panelReady.gameObject.SetActive(true);
        }
        if (mode == 3)
        {
            textInputNameHeroes.text = "Лара Крофт";
            Globals.mainCharacter = "laraCroft";
            animationController.GetComponent<Animator>().enabled = true;
            animationController.GetComponent<Animator>().Play("player3Anim", -1);
            readyHeroes.GetComponent<Image>().sprite = laraCroft;
            info.GetComponent<Text>().text = "визуально - ловкая, может избежать последствий попадания в одну ловушку (с перезарядкой) 1 слот под артефакты";
            //panelReady.gameObject.SetActive(true);
        }
        if (mode == 4)
        {
            textInputNameHeroes.text = "Монти Холл";
            animationController.GetComponent<Animator>().enabled = true;
            animationController.GetComponent<Animator>().Play("player4Anim", -1);
            Globals.mainCharacter = "montyHoll";
            readyHeroes.GetComponent<Image>().sprite = montyHoll;
            info.GetComponent<Text>().text = "визуально - ученый,если перед ним 3 клетки, может посмотреть(вскрыть) одну из них, и после этого принять решение, куда двигаться. 2 слота под артефакты";
            //panelReady.gameObject.SetActive(true);
        }
        if (mode == 5)
        {
            textInputNameHeroes.text = "Нострадама";
            Globals.mainCharacter = "nostradama"; 
            animationController.GetComponent<Animator>().enabled = true;
            animationController.GetComponent<Animator>().Play("player5Anim", -1);
            readyHeroes.GetComponent<Image>().sprite = nostradama;
            info.GetComponent<Text>().text = "визуально - предсказательница. с 25 % -й вероятностью знает, в каком блоке перед ней ловушка 1 слот для артефактов";
            //panelReady.gameObject.SetActive(true);
        }


    }

    // Start is called before the first frame update
    void Start()
    {
        //panelReady.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
